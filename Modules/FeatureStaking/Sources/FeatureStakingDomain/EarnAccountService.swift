// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Combine

public struct EarnProduct: NewTypeString {
    public var value: String
    public init(_ value: String) { self.value = value }
}

extension EarnProduct {
    public static let staking: Self = "staking"
    public static let savings: Self = "savings"
}

private let id = blockchain.user.earn.product.asset

public final class EarnAccountService {

    private let app: AppProtocol
    private let repository: EarnRepositoryAPI

    var context: Tag.Context {
        [blockchain.user.earn.product.id: repository.product]
    }

    public init(
        app: AppProtocol,
        repository: EarnRepositoryAPI
    ) {
        self.app = app
        self.repository = repository
    }

    public func balance(for currency: CryptoCurrency) -> AnyPublisher<EarnAccount?, UX.Error> {
        Task.Publisher { [weak self, app] () -> EarnAccount? in
            guard let self else { return nil }
            guard try await app.get(blockchain.user.is.tier.gold) else { return nil }
            return try await self.balances().await()[currency.code]
        }
        .mapError(UX.Error.init)
        .eraseToAnyPublisher()
    }

    public func balances() -> AnyPublisher<EarnAccounts, UX.Error> {
        Task.Publisher { [app, repository] () -> EarnAccounts in
            try await repository.balances(in: app.get(blockchain.user.currency.preferred.fiat.display.currency)).await()
        }
        .handleEvents(
            receiveOutput: { [app, context] balances in
                Task {
                    try await app.batch(
                        updates: balances.reduce(into: [(Tag.Event, Any?)]()) { data, next in
                            data.append((id[next.key].account.balance, next.value.balance?.moneyValue.data))
                            data.append((id[next.key].account.bonding.deposits, next.value.bondingDeposits?.moneyValue.data))
                            data.append((id[next.key].account.locked, next.value.locked?.moneyValue.data))
                            data.append((id[next.key].account.pending.deposit, next.value.pendingDeposit?.moneyValue.data))
                            data.append((id[next.key].account.pending.withdrawal, next.value.pendingWithdrawal?.moneyValue.data))
                            data.append((id[next.key].account.total.rewards, next.value.totalRewards?.moneyValue.data))
                            data.append((id[next.key].account.unbonding.withdrawals, next.value.unbondingWithdrawals?.moneyValue.data))
                        },
                        in: context
                    )
                }
            }
        )
        .mapError(UX.Error.init)
        .eraseToAnyPublisher()
    }

    public func invalidateBalances() {
        repository.invalidateBalances()
    }

    public func eligibility() -> AnyPublisher<EarnEligibility, UX.Error> {
        repository.eligibility()
            .handleEvents(
                receiveOutput: { [app, context] eligibility in
                    Task {
                        try await app.batch(
                            updates: eligibility.reduce(into: [(Tag.Event, Any?)]()) { data, next in
                                data.append((id[next.key].is.eligible, next.value.eligible))
                            },
                            in: context
                        )
                    }
                }
            )
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    public func userRates() -> AnyPublisher<EarnUserRates, UX.Error> {
        repository.userRates()
            .handleEvents(
                receiveOutput: { [app, context] user in
                    Task {
                        try await app.batch(
                            updates: user.rates.reduce(into: [(Tag.Event, Any?)]()) { data, next in
                                data.append((id[next.key].rates.commission, next.value.commission.map { $0 / 100 }))
                                data.append((id[next.key].rates.rate, next.value.rate / 100))
                            },
                            in: context
                        )
                    }
                }
            )
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    public func limits() -> AnyPublisher<EarnLimits, UX.Error> {
        repository.limits()
            .handleEvents(
                receiveOutput: { [app, context] limits in
                    Task {
                        try await app.batch(
                            updates: limits.reduce(into: [(Tag.Event, Any?)]()) { data, next in
                                data.append((id[next.key].limit.days.bonding, next.value.bondingDays ?? 0))
                                data.append((id[next.key].limit.days.unbonding, next.value.unbondingDays ?? 0))
                                data.append((id[next.key].limit.minimum.deposit.value, next.value.minDepositValue))
                                data.append((id[next.key].limit.withdraw.is.disabled, next.value.disabledWithdrawals ?? false))
                                data.append((id[next.key].limit.reward.frequency, { () -> Tag? in
                                    switch next.value.rewardFrequency?.uppercased() {
                                    case "DAILY": return id.limit.reward.frequency.daily[]
                                    case "WEEKLY": return id.limit.reward.frequency.weekly[]
                                    case "MONTHLY": return id.limit.reward.frequency.monthly[]
                                    case _: return nil
                                    }
                                }()))
                            },
                            in: context
                        )
                    }
                }
            )
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    public func address(currency: CryptoCurrency) -> AnyPublisher<EarnAddress, UX.Error> {
        repository.address(currency: currency)
            .handleEvents(
                receiveOutput: { [app, context] address in
                    Task {
                        try await app.set(id[currency.code].address.key(to: context), to: address.accountRef)
                    }
                }
            )
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    public func activity(currency: CryptoCurrency) -> AnyPublisher<[EarnActivity], UX.Error> {
        repository.activity(currency: currency)
            .handleEvents(
                receiveOutput: { [app, context] activity in
                    Task {
                        try await app.set(id[currency.code].activity.key(to: context), to: activity.json())
                    }
                }
            )
            .mapError(UX.Error.init)
            .eraseToAnyPublisher()
    }

    public func deposit(amount: MoneyValue) -> AnyPublisher<Void, UX.Error> {
        repository.deposit(amount: amount).mapError(UX.Error.init).eraseToAnyPublisher()
    }

    public func withdraw(amount: MoneyValue) -> AnyPublisher<Void, UX.Error> {
        repository.withdraw(amount: amount).mapError(UX.Error.init).eraseToAnyPublisher()
    }
}

extension MoneyValue {

    var data: [String: Any] {
        [
            "amount": minorString,
            "currency": code
        ]
    }
}
