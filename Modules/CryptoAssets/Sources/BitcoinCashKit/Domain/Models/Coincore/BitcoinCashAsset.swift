// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import DIKit
import FeatureCryptoDomainDomain
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

private struct AccountsPayload {
    let defaultAccount: BitcoinCashWalletAccount
    let accounts: [BitcoinCashWalletAccount]
}

final class BitcoinCashAsset: CryptoAsset {

    // MARK: - Properties

    let asset: CryptoCurrency = .bitcoinCash

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        repository.defaultAccount
            .mapError(CryptoAssetError.failedToLoadDefaultAccount)
            .map { account in
                BitcoinCashCryptoAccount(
                    xPub: account.publicKey,
                    label: account.label,
                    isDefault: true,
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
        addressFactory: addressFactory,
        featureFlag: featureFlag
    )

    private let addressFactory: ExternalAssetAddressFactory
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let repository: BitcoinCashWalletAccountRepository
    private let kycTiersService: KYCTiersServiceAPI
    private let featureFlag: FeatureFetching

    // MARK: - Setup

    init(
        addressFactory: ExternalAssetAddressFactory = resolve(
            tag: BitcoinChainCoin.bitcoinCash
        ),
        errorRecorder: ErrorRecording = resolve(),
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        repository: BitcoinCashWalletAccountRepository = resolve(),
        featureFlag: FeatureFetching = resolve()
    ) {
        self.addressFactory = addressFactory
        self.errorRecorder = errorRecorder
        self.exchangeAccountProvider = exchangeAccountProvider
        self.kycTiersService = kycTiersService
        self.repository = repository
        self.featureFlag = featureFlag
    }

    // MARK: - Methods

    func initialize() -> AnyPublisher<Void, AssetError> {
        // Run wallet renaming procedure on initialization.
        cryptoAssetRepository
            .nonCustodialGroup
            .compactMap { $0 }
            .map(\.accounts)
            .flatMap { [upgradeLegacyLabels] accounts in
                upgradeLegacyLabels(accounts)
            }
            .mapError()
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

extension BitcoinCashAsset: DomainResolutionRecordProviderAPI {

    var resolutionRecord: AnyPublisher<ResolutionRecord, Error> {
        resolutionRecordAccount
            .eraseError()
            .flatMap { account in
                account.firstReceiveAddress.eraseError()
            }
            .map { [asset] receiveAddress in
                ResolutionRecord(symbol: asset.code, walletAddress: receiveAddress.address)
            }
            .eraseToAnyPublisher()
    }

    private var resolutionRecordAccount: AnyPublisher<BitcoinCashCryptoAccount, BitcoinCashWalletRepositoryError> {
        repository
            .accounts
            .map { accounts -> BitcoinCashWalletAccount? in
                accounts.first(where: { $0.index == 0 })
            }
            .onNil(.missingWallet)
            .map { account in
                BitcoinCashCryptoAccount(
                    xPub: account.publicKey,
                    label: account.label ?? CryptoCurrency.bitcoinCash.defaultWalletName,
                    isDefault: false,
                    hdAccountIndex: account.index
                )
            }
            .eraseToAnyPublisher()
    }
}
