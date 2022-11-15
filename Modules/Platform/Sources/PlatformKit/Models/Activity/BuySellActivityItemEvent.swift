// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import MoneyKit

public struct BuySellActivityItemEvent {

    public enum EventStatus {
        case pending
        case pendingConfirmation
        case cancelled
        case failed
        case expired
        case finished
    }

    public enum PaymentMethod {
        case card(paymentMethodId: String?)
        case applePay
        case bankTransfer
        case bankAccount
        case funds
    }

    public var currencyType: CurrencyType {
        outputValue.currency
    }

    public let isBuy: Bool
    public let isCancellable: Bool
    public let paymentProcessorErrorOccurred: Bool
    public let status: EventStatus
    public let paymentMethod: PaymentMethod
    public let recurringBuyId: String?

    public let identifier: String

    public let creationDate: Date

    public let inputValue: MoneyValue
    public let outputValue: MoneyValue
    public var fee: MoneyValue

    public init(
        identifier: String,
        creationDate: Date,
        status: EventStatus,
        inputValue: MoneyValue,
        outputValue: MoneyValue,
        fee: MoneyValue,
        isBuy: Bool,
        isCancellable: Bool,
        paymentMethod: PaymentMethod,
        recurringBuyId: String? = nil,
        paymentProcessorErrorOccurred: Bool = false
    ) {
        self.isBuy = isBuy
        self.isCancellable = isCancellable
        self.creationDate = creationDate
        self.identifier = identifier
        self.status = status
        self.inputValue = inputValue
        self.outputValue = outputValue
        self.fee = fee
        self.paymentMethod = paymentMethod
        self.paymentProcessorErrorOccurred = paymentProcessorErrorOccurred
        self.recurringBuyId = recurringBuyId
    }
}

extension BuySellActivityItemEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension BuySellActivityItemEvent: Equatable {
    public static func == (lhs: BuySellActivityItemEvent, rhs: BuySellActivityItemEvent) -> Bool {
        lhs.identifier == rhs.identifier &&
            lhs.status == rhs.status
    }
}

extension BuySellActivityItemEvent {

    /// Creates a buy sell activity item event.
    ///
    /// Some sell activities are retrieved as swaps from a crypto currency to a fiat currency, and they should be mapped using this initializer.
    ///
    /// - Parameter swapActivityItemEvent: A swap activity item event.
    public init(swapActivityItemEvent: SwapActivityItemEvent) {
        isBuy = false
        isCancellable = false
        creationDate = swapActivityItemEvent.date
        identifier = swapActivityItemEvent.identifier
        inputValue = swapActivityItemEvent.amounts.withdrawal
        outputValue = swapActivityItemEvent.amounts.deposit
        fee = swapActivityItemEvent.amounts.withdrawalFee
        paymentMethod = .funds
        paymentProcessorErrorOccurred = false
        recurringBuyId = nil

        switch swapActivityItemEvent.status {
        case .complete:
            status = .finished
        case .delayed:
            status = .pending
        case .expired:
            status = .expired
        case .failed:
            status = .failed
        case .inProgress:
            status = .pending
        case .none:
            status = .pending
        case .pendingRefund:
            status = .pending
        case .refunded:
            status = .cancelled
        }
    }
}
