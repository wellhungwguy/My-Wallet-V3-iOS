// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
import DIKit
import MoneyKit
import RxSwift
import ToolKit

final class CustodialCryptoAsset: CryptoAsset {

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        .failure(.noDefaultAccount)
    }

    let asset: CryptoCurrency

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

    private let kycTiersService: KYCTiersServiceAPI
    private let errorRecorder: ErrorRecording
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let addressFactory: ExternalAssetAddressFactory
    private let featureFetcher: FeatureFetching
    private let delegatedCustodyAccountRepository: DelegatedCustodyAccountRepositoryAPI

    // MARK: - Setup

    init(
        asset: CryptoCurrency,
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        delegatedCustodyAccountRepository: DelegatedCustodyAccountRepositoryAPI = resolve()
    ) {
        self.asset = asset
        self.kycTiersService = kycTiersService
        self.exchangeAccountProvider = exchangeAccountProvider
        self.errorRecorder = errorRecorder
        self.featureFetcher = featureFetcher
        self.delegatedCustodyAccountRepository = delegatedCustodyAccountRepository
        addressFactory = PlainCryptoReceiveAddressFactory(asset: asset)
    }

    // MARK: - Asset

    func initialize() -> AnyPublisher<Void, AssetError> {
        Just(())
            .mapError(to: AssetError.self)
            .eraseToAnyPublisher()
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup, Never> {
        switch filter {
        case .all:
            return allAccountsGroup
        case .custodial:
            return custodialGroup
        case .interest:
            return interestGroup
        case .nonCustodial:
            return nonCustodialGroup
        case .exchange:
            return exchangeGroup
        }
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        addressFactory
            .makeExternalAssetAddress(
                address: address,
                label: address,
                onTxCompleted: { _ in .empty() }
            )
            .publisher
            .map { address -> ReceiveAddress? in
                address
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        addressFactory.makeExternalAssetAddress(
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        )
    }

    private var allAccountsGroup: AnyPublisher<AccountGroup, Never> {
        [
            nonCustodialGroup,
            custodialGroup,
            interestGroup,
            exchangeGroup
        ]
        .zip()
        .eraseToAnyPublisher()
        .flatMapAllAccountGroup()
    }

    private var exchangeGroup: AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.exchangeGroup
    }

    private var custodialGroup: AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.custodialGroup
    }

    private var interestGroup: AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.interestGroup
    }

    private var nonCustodialGroup: AnyPublisher<AccountGroup, Never> {
        delegatedCustodyAccount
            .map { [asset, addressFactory] delegatedCustodyAccount in
                guard let delegatedCustodyAccount = delegatedCustodyAccount else {
                    return CryptoAccountNonCustodialGroup(
                        asset: asset,
                        accounts: []
                    )
                }
                let account = CryptoDelegatedCustodyAccount(
                    activityRepository: resolve(),
                    addressesRepository: resolve(),
                    addressFactory: addressFactory,
                    asset: delegatedCustodyAccount.coin,
                    balanceRepository: resolve(),
                    priceService: resolve(),
                    publicKey: delegatedCustodyAccount.publicKey.hex
                )
                return CryptoAccountNonCustodialGroup(
                    asset: asset,
                    accounts: [account]
                )
            }
            .eraseToAnyPublisher()
    }

    private var delegatedCustodyAccount: AnyPublisher<DelegatedCustodyAccount?, Never> {
        delegatedCustodyAccountRepository
            .delegatedCustodyAccounts
            .map { [asset] accounts in
                accounts.first(where: { $0.coin == asset })
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
