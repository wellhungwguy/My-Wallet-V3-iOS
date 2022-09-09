// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol CryptoNonCustodialAccount: CryptoAccount, NonCustodialAccount {

    func updateLabel(_ newLabel: String) -> AnyPublisher<Void, Never>

    /// Creates and return a On Chain `TransactionEngine` for this account `CryptoCurrency`.
    func createTransactionEngine() -> Any
}

extension CryptoNonCustodialAccount {

    public var accountType: AccountType {
        .nonCustodial
    }

    public var isBitPaySupported: Bool {
        if asset == .bitcoin {
            return true
        }

        return false
    }

    public func updateLabel(_ newLabel: String) -> AnyPublisher<Void, Never> {
        .just(())
    }

    public var canPerformInterestTransfer: AnyPublisher<Bool, Never> {
        disabledReason.map(\.isEligible)
            .zip(isFunded)
            .map { isEligible, isFunded in
                isEligible && isFunded
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    /// The `OrderDirection` for which an `CryptoNonCustodialAccount` could have custodial events.
    public var custodialDirections: Set<OrderDirection> {
        [.fromUserKey, .onChain]
    }

    /// Treats an `[TransactionalActivityItemEvent]`, replacing any event matching one of the `SwapActivityItemEvent` with the said match.
    public static func reconcile(
        swapEvents: [SwapActivityItemEvent],
        noncustodial: [TransactionalActivityItemEvent]
    ) -> [ActivityItemEvent] {
        (noncustodial.map(ActivityItemEvent.transactional) + swapEvents.map(ActivityItemEvent.swap))
            .map { event in
                if case .swap(let swapEvent) = event, swapEvent.pair.outputCurrencyType.isFiatCurrency {
                    return .buySell(.init(swapActivityItemEvent: swapEvent))
                }
                return event
            }
    }
}
