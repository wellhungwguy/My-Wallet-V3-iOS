// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

/// Similar to TransactionalActivityItemEvent, but we won't fetch any more data for it.
public struct SimpleTransactionalActivityItemEvent: Hashable {

    public enum EventStatus: Equatable {
        public struct Confirmations: Equatable {
            /// How many confirmations have taken place
            public let current: Int
            /// The total number of confirmations required
            public let total: Int

            public init(current: Int, total: Int) {
                self.current = current
                self.total = total
            }
        }

        /// The event is pending confirmation
        case pending(confirmations: Confirmations)
        /// The event has completed
        case complete
    }

    public enum EventType: Equatable {
        /// Send transaction
        case send
        /// Transaction was received
        case receive
    }

    public let creationDate: Date

    /**
     The transaction identifier, used for equality checking and backend calls.

     - Note: This is identical to `transactionHash` for all crypto assets, except Stellar. See `StellarHistoricalTransaction` for more info.
     */
    public let identifier: String
    /// The transaction hash, used in Explorer URLs.
    public let transactionHash: String

    public let sourceAddress: String?
    public let destinationAddress: String?

    public let memo: String?

    public let status: EventStatus
    public let type: EventType

    public let amount: CryptoValue
    public let fee: CryptoValue

    public var currency: CryptoCurrency {
        amount.currency
    }

    public init(
        amount: CryptoValue,
        creationDate: Date,
        destinationAddress: String?,
        fee: CryptoValue?,
        identifier: String,
        memo: String?,
        sourceAddress: String?,
        status: EventStatus,
        transactionHash: String,
        type: EventType
    ) {
        self.amount = amount
        self.creationDate = creationDate
        self.destinationAddress = destinationAddress
        self.fee = fee ?? .zero(currency: amount.currency)
        self.identifier = identifier
        self.memo = memo
        self.sourceAddress = sourceAddress
        self.status = status
        self.transactionHash = transactionHash
        self.type = type
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
