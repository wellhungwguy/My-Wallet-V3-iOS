// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCryptoDomainDomain
import MoneyKit
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

final class StellarAsset: CryptoAsset {

    // MARK: - Properties

    let asset: CryptoCurrency = .stellar

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        accountRepository
            .defaultAccount
            .setFailureType(to: CryptoAssetError.self)
            .onNil(CryptoAssetError.noDefaultAccount)
            .map { account -> SingleAccount in
                StellarCryptoAccount(
                    publicKey: account.publicKey,
                    label: account.label,
                    hdAccountIndex: account.index
                )
            }
            .eraseToAnyPublisher()
    }

    var canTransactToCustodial: AnyPublisher<Bool, Never> {
        cryptoAssetRepository.canTransactToCustodial
    }

    // MARK: - Private properties

    private lazy var cryptoAssetRepository: CryptoAssetRepositoryAPI = CryptoAssetRepository(
        asset: asset,
        errorRecorder: errorRecorder,
        kycTiersService: kycTiersService,
        defaultAccountProvider: { [defaultAccount] in
            defaultAccount
        },
        exchangeAccountsProvider: exchangeAccountProvider,
        addressFactory: addressFactory
    )

    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let accountRepository: StellarWalletAccountRepositoryAPI
    private let errorRecorder: ErrorRecording
    private let addressFactory: StellarCryptoReceiveAddressFactory
    private let kycTiersService: KYCTiersServiceAPI

    // MARK: - Setup

    init(
        accountRepository: StellarWalletAccountRepositoryAPI,
        errorRecorder: ErrorRecording,
        exchangeAccountProvider: ExchangeAccountsProviderAPI,
        kycTiersService: KYCTiersServiceAPI,
        addressFactory: StellarCryptoReceiveAddressFactory
    ) {
        self.exchangeAccountProvider = exchangeAccountProvider
        self.accountRepository = accountRepository
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
        self.addressFactory = addressFactory
    }

    // MARK: - Methods

    func initialize() -> AnyPublisher<Void, AssetError> {
        accountRepository.initializeMetadata()
            .flatMap { [cryptoAssetRepository, upgradeLegacyLabels] _ in
                cryptoAssetRepository
                    .nonCustodialGroup
                    .compactMap { $0 }
                    .map(\.accounts)
                    .flatMap { [upgradeLegacyLabels] accounts in
                        upgradeLegacyLabels(accounts)
                    }
            }
            .mapError { _ in .initialisationFailed }
            .eraseToAnyPublisher()
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {
        cryptoAssetRepository.accountGroup(filter: filter)
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        cryptoAssetRepository.parse(address: address)
    }

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        cryptoAssetRepository.parse(address: address, label: label, onTxCompleted: onTxCompleted)
    }
}

extension StellarAsset: DomainResolutionRecordProviderAPI {

    var resolutionRecord: AnyPublisher<ResolutionRecord, Error> {
        defaultAccount
            .eraseError()
            .flatMap { account -> AnyPublisher<ReceiveAddress, Error> in
                account.receiveAddress
            }
            .map { [asset] receiveAddress in
                ResolutionRecord(symbol: asset.code, walletAddress: receiveAddress.address)
            }
            .eraseToAnyPublisher()
    }
}
