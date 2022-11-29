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

    var stakingGroup: AnyPublisher<AccountGroup?, Never> { get }

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

    public typealias DefaultAccountProvider = () -> AnyPublisher<SingleAccount, CryptoAssetError>

    public typealias ExchangeAccountProvider = () -> AnyPublisher<CryptoExchangeAccount?, Never>

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
            stakingGroup,
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
            interestGroup,
            stakingGroup
        ]
            .zip()
            .compactMap { $0 }
            .eraseToAnyPublisher()
            .flatMapAllAccountGroup()
    }

    public var custodialAndInterestGroup: AnyPublisher<AccountGroup?, Never> {
        [
            custodialGroup,
            interestGroup,
            stakingGroup
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
                guard let account else {
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

    public var stakingGroup: AnyPublisher<AccountGroup?, Never> {
        guard asset.supports(product: .stakingBalance) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return .just(
            CryptoAccountCustodialGroup(
                asset: asset,
                account: CryptoStakingAccount(
                    asset: asset
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
    private let featureFlag: FeatureFetching

    // MARK: - Setup

    public init(
        asset: CryptoCurrency,
        errorRecorder: ErrorRecording,
        kycTiersService: KYCTiersServiceAPI,
        defaultAccountProvider: @escaping DefaultAccountProvider,
        exchangeAccountsProvider: ExchangeAccountsProviderAPI,
        addressFactory: ExternalAssetAddressFactory,
        featureFlag: FeatureFetching
    ) {
        self.asset = asset
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
        self.defaultAccountProvider = defaultAccountProvider
        self.exchangeAccountsProvider = exchangeAccountsProvider
        self.addressFactory = addressFactory
        self.featureFlag = featureFlag
    }

    // MARK: - Public methods

    public func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup?, Never> {
        var stream: [AnyPublisher<SingleAccount?, Never>] = []
        if filter.contains(.custodial) {
            stream.append(custodialAccount)
        }

        if filter.contains(.interest) {
            stream.append(interestAccount)
        }

        if filter.contains(.nonCustodial) {
            let publisher = defaultAccountProvider()
                .map { $0 as SingleAccount? }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
            stream.append(publisher)
        }

        if filter.contains(.staking) {
            stream.append(stakingAccount)
        }

        if filter.contains(.exchange) {
            stream.append(exchangeAccount)
        }

        return stream
            .zip()
            .map { accounts in
                AllAccountsGroup(accounts: accounts.compactMap { $0 })
            }
            .eraseToAnyPublisher()
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

    public var stakingAccount: AnyPublisher<SingleAccount?, Never> {
        featureFlag.isEnabled(.staking)
            .flatMap { [asset] isEnabled -> AnyPublisher<SingleAccount?, Never> in
                guard isEnabled else {
                    return .just(nil)
                }
                guard asset.supports(product: .stakingBalance) else {
                    return .just(nil)
                }
                return .just(
                    CryptoStakingAccount(
                        asset: asset
                    )
                )
            }
            .eraseToAnyPublisher()
    }

    public var exchangeAccount: AnyPublisher<SingleAccount?, Never> {
        guard asset.supports(product: .mercuryDeposits) else {
            return .just(nil)
        }
        return exchangeAccountsProvider
            .account(
                for: asset,
                externalAssetAddressFactory: addressFactory
            )
            .optional()
            .replaceError(with: nil)
            .map { $0 as SingleAccount? }
            .eraseToAnyPublisher()
    }

    public var interestAccount: AnyPublisher<SingleAccount?, Never> {
        guard asset.supports(product: .interestBalance) else {
            return .just(nil)
        }
        return .just(
            CryptoInterestAccount(
                asset: asset,
                cryptoReceiveAddressFactory: addressFactory
            )
        )
    }

    public var custodialAccount: AnyPublisher<SingleAccount?, Never> {
        guard asset.supports(product: .custodialWalletBalance) else {
            return .just(nil)
        }
        return .just(
            CryptoTradingAccount(
                asset: asset,
                cryptoReceiveAddressFactory: addressFactory
            )
        )
    }
}
