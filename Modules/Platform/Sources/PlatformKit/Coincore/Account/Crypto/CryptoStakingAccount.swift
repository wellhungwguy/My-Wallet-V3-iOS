// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Localization
import MoneyKit
import RxSwift
import ToolKit

public final class CryptoStakingAccount: CryptoAccount, StakingAccount {
    public var activity: AnyPublisher<[ActivityItemEvent], Error> {
        .just([])
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
        .failure(ReceiveAddressError.notSupported)
    }

    public var firstReceiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(ReceiveAddressError.notSupported)
    }

    public var isFunded: AnyPublisher<Bool, Error> {
        balances
            .map { $0 != .absent }
            .eraseError()
    }

    private let priceService: PriceServiceAPI
    private let balanceService: StakingAccountOverviewAPI
    private var balances: AnyPublisher<CustodialAccountBalanceState, Never> {
        balanceService.balance(for: asset)
    }

    public init(
        asset: CryptoCurrency,
        balanceService: StakingAccountOverviewAPI = resolve(),
        priceService: PriceServiceAPI = resolve()
    ) {
        label = asset.defaultStakingWalletName
        self.asset = asset
        self.balanceService = balanceService
        self.priceService = priceService
    }

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        // no-op on staking at the moment, only activity
        .just(false)
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

    public func invalidateAccountBalance() {
        balanceService.invalidateAccountBalances()
    }
}
