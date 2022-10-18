// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import MoneyKit
import RxSwift
import ToolKit

public protocol CryptoAssetRepositoryAPI {

    var allAccountsGroup: AnyPublisher<AccountGroup?, Never> { get }

    var allExcludingExchangeAccountsGroup: AnyPublisher<AccountGroup?, Never> { get }

    var custodialGroup: AnyPublisher<AccountGroup?, Never> { get }

    var nonCustodialGroup: AnyPublisher<AccountGroup?, Never> { get }

    var exchangeGroup: AnyPublisher<AccountGroup?, Never> { get }

    var interestGroup: AnyPublisher<AccountGroup?, Never> { get }

    var custodialAndInterestGroup: AnyPublisher<AccountGroup?, Never> { get }

    var canTransactToCustodial: AnyPublisher<Bool, Never> { get }

    func accountGroup(
        filter: AssetFilter
    ) -> AnyPublisher<AccountGroup?, Never>

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never>

    func parse(
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError>
}

public final class CryptoAssetRepository: CryptoAssetRepositoryAPI {

    // MARK: - Types

    public typealias DefaultAccountProvider =
        () -> AnyPublisher<SingleAccount, CryptoAssetError>

    public typealias ExchangeAccountProvider =
        () -> AnyPublisher<CryptoExchangeAccount?, Never>

    // MARK: - Properties

    public var nonCustodialGroup: AnyPublisher<AccountGroup?, Never> {
        defaultAccountProvider()
            .map { [asset] account -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: [account])
            }
            .recordErrors(on: errorRecorder)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    public var canTransactToCustodial: AnyPublisher<Bool, Never> {
        kycTiersService.tiers
            .map { tiers in
                tiers.isTier1Approved || tiers.isTier2Approved
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    public var allAccountsGroup: AnyPublisher<AccountGroup?, Never> {
        [
            nonCustodialGroup,
            custodialGroup,
            interestGroup,
            exchangeGroup
        ]
        .zip()
        .compactMap { $0 }
        .eraseToAnyPublisher()
        .flatMapAllAccountGroup()
    }

    public var allExcludingExchangeAccountsGroup: AnyPublisher<AccountGroup?, Never> {
        [
            nonCustodialGroup,
            custodialGroup,
            interestGroup
        ]
        .zip()
        .compactMap { $0 }
        .eraseToAnyPublisher()
        .flatMapAllAccountGroup()
    }

    public var custodialAndInterestGroup: AnyPublisher<AccountGroup?, Never> {
        [
            custodialGroup,
            interestGroup
        ]
        .zip()
        .compactMap { $0 }
        .eraseToAnyPublisher()
        .flatMapAllAccountGroup()
    }

    public var exchangeGroup: AnyPublisher<AccountGroup?, Never> {
        guard asset.supports(product: .mercuryDeposits) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return exchangeAccountsProvider
            .account(
                for: asset,
                externalAssetAddressFactory: addressFactory
            )
            .optional()
            .replaceError(with: nil)
            .map { [asset] account -> CryptoAccountCustodialGroup in
                guard let account = account else {
                    return CryptoAccountCustodialGroup(asset: asset)
                }
                return CryptoAccountCustodialGroup(asset: asset, account: account)
            }
            .eraseToAnyPublisher()
    }

    public var interestGroup: AnyPublisher<AccountGroup?, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return .just(
            CryptoAccountCustodialGroup(
                asset: asset,
                account: CryptoInterestAccount(
                    asset: asset,
                    cryptoReceiveAddressFactory: addressFactory
                )
            )
        )
    }

    public var custodialGroup: AnyPublisher<AccountGroup?, Never> {
        guard asset.supports(product: .custodialWalletBalance) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return .just(
            CryptoAccountCustodialGroup(
                asset: asset,
                account: CryptoTradingAccount(
                    asset: asset,
                    cryptoReceiveAddressFactory: addressFactory
                )
            )
        )
    }

    // MARK: - Private properties

    private let asset: CryptoCurrency
    private let errorRecorder: ErrorRecording
    private let kycTiersService: KYCTiersServiceAPI
    private let defaultAccountProvider: DefaultAccountProvider
    private let exchangeAccountsProvider: ExchangeAccountsProviderAPI
    private let addressFactory: ExternalAssetAddressFactory

    // MARK: - Setup

    public init(
        asset: CryptoCurrency,
        errorRecorder: ErrorRecording,
        kycTiersService: KYCTiersServiceAPI,
        defaultAccountProvider: @escaping DefaultAccountProvider,
        exchangeAccountsProvider: ExchangeAccountsProviderAPI,
        addressFactory: ExternalAssetAddressFactory
    ) {
        self.asset = asset
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
        self.defaultAccountProvider = defaultAccountProvider
        self.exchangeAccountsProvider = exchangeAccountsProvider
        self.addressFactory = addressFactory
    }

    // MARK: - Public methods

    public func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {
        switch filter {
        case .all:
            return allAccountsGroup
        case .allExcludingExchange:
            return allExcludingExchangeAccountsGroup
        case .custodial:
            return custodialGroup
        case .interest:
            return interestGroup
        case .nonCustodial:
            return nonCustodialGroup
        case .exchange:
            return exchangeGroup
        case [.custodial, .interest]:
            return custodialAndInterestGroup
        default:
            return .just(nil)
        }
    }

    public func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        let receiveAddress = try? parse(
            address: address,
            label: address,
            onTxCompleted: { _ in .empty() }
        )
        .get()
        return .just(receiveAddress)
    }

    public func parse(
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
}
