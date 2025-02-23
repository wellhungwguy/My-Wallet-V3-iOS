// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureStakingDomain
import Localization
import MoneyKit
import RxSwift
import ToolKit

public final class CryptoStakingAccount: CryptoAccount, StakingAccount {

    public var activity: AnyPublisher<[ActivityItemEvent], Error> {
        earn.activity(currency: asset)
            .map { activity in
                activity.map(ActivityItemEvent.staking)
            }
            .eraseError()
            .eraseToAnyPublisher()
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        balances
            .map(\.balance?.available)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var pendingBalance: AnyPublisher<MoneyDomainKit.MoneyValue, Error> {
        balances
            .map(\.balance?.pending)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public var actionableBalance: AnyPublisher<MoneyDomainKit.MoneyValue, Error> {
        balances
            .map(\.balance)
            .map(\.?.withdrawable)
            .replaceNil(with: .zero(currency: currencyType))
            .eraseError()
    }

    public private(set) lazy var identifier: AnyHashable = "CryptoStakingAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false
    public var accountType: AccountType = .trading

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        earn.address(currency: asset)
            .tryMap { [asset, cryptoReceiveAddressFactory, onTxCompleted] address throws -> ReceiveAddress in
                try cryptoReceiveAddressFactory.makeExternalAssetAddress(
                    address: address.accountRef,
                    label: "\(asset.code) \(LocalizationConstants.stakingAccount)",
                    onTxCompleted: onTxCompleted
                )
                .get() as ReceiveAddress
            }
            .eraseToAnyPublisher()
    }

    public var isFunded: AnyPublisher<Bool, Error> {
        balances
            .map { $0 != .absent }
            .eraseError()
    }

    private let priceService: PriceServiceAPI
    private let earn: EarnAccountService
    private let cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    private let subscription: AnyCancellable

    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        earn.balances()
            .map(CustodialAccountBalanceStates.init(accounts:))
            .map(\.[asset.currencyType])
            .replaceError(with: CustodialAccountBalanceState.absent)
            .eraseToAnyPublisher()
    }

    public init(
        asset: CryptoCurrency,
        earn: EarnAccountService = resolve(tag: EarnProduct.staking),
        priceService: PriceServiceAPI = resolve(),
        cryptoReceiveAddressFactory: ExternalAssetAddressFactory
    ) {
        self.label = asset.defaultStakingWalletName
        self.asset = asset
        self.earn = earn
        self.priceService = priceService
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory

        self.subscription = [
            earn.limits().mapToVoid(),
            earn.eligibility().mapToVoid(),
            earn.userRates().mapToVoid(),
            earn.balances().mapToVoid(),
            earn.activity(currency: asset).mapToVoid()
        ]
        .combineLatest()
        .subscribe()
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .viewActivity:
            return .just(true)
        case _:
            return .just(false)
        }
    }

    public func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func mainBalanceToDisplayPair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        mainBalanceToDisplayPair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    public func invalidateAccountBalance() {
        earn.invalidateBalances()
    }
}

extension CustodialAccountBalance {

    init?(account: EarnAccount) {
        guard let balance = account.balance else { return nil }
        let zero: MoneyValue = .zero(currency: balance.currency)
        let locked = account.locked?.moneyValue ?? zero
        self.init(
            currency: balance.currencyType,
            available: balance.moneyValue,
            withdrawable: (try? balance.moneyValue - locked).or(zero),
            pending: (account.pendingDeposit?.moneyValue).or(zero),
            mainBalanceToDisplay: balance.moneyValue
        )
    }
}

extension CustodialAccountBalanceStates {

    init(accounts: EarnAccounts) {
        let balances = accounts.reduce(into: [CurrencyType: CustodialAccountBalanceState]()) { result, item in
            guard let currency = CryptoCurrency(code: item.key) else { return }
            guard let account = CustodialAccountBalance(account: item.value) else { return }
            result[currency.currencyType] = .present(account)
        }
        self = .init(balances: balances)
    }
}
