// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit

enum StellarHistoricalTransaction {

    var fee: CryptoValue? {
        switch self {
        case .accountCreated(let value):
            guard let fee = value.fee else { return nil }
            return CryptoValue.create(minor: BigInt(fee), currency: .stellar)
        case .payment(let value):
            guard let fee = value.fee else { return nil }
            return CryptoValue.create(minor: BigInt(fee), currency: .stellar)
        }
    }

    var memo: String? {
        switch self {
        case .accountCreated(let value):
            return value.memo
        case .payment(let value):
            return value.memo
        }
    }

    /**
     The transaction identifier, used for equality checking and backend calls.

     - Note:
        For Stellar, this is different than `transactionHash`.
        See [Stellar Operation Object](https://developers.stellar.org/api/resources/operations/object/) for more info.
     */
    var identifier: String {
        switch self {
        case .accountCreated(let value):
            return value.identifier
        case .payment(let value):
            return value.identifier
        }
    }

    var fromAddress: StellarAssetAddress {
        switch self {
        case .accountCreated(let value):
            return StellarAssetAddress(publicKey: value.funder)
        case .payment(let value):
            return StellarAssetAddress(publicKey: value.fromAccount)
        }
    }

    var toAddress: StellarAssetAddress {
        switch self {
        case .accountCreated(let value):
            return StellarAssetAddress(publicKey: value.account)
        case .payment(let value):
            return StellarAssetAddress(publicKey: value.toAccount)
        }
    }

    var direction: Direction {
        switch self {
        case .accountCreated(let value):
            return value.direction
        case .payment(let value):
            return value.direction
        }
    }

    var amount: CryptoValue {
        switch self {
        case .accountCreated(let value):
            return CryptoValue.create(major: value.balance, currency: .stellar)
        case .payment(let value):
            return CryptoValue.create(major: value.amount, currency: .stellar) ?? .zero(currency: .stellar)
        }
    }

    /// The transaction hash, used in Explorer URLs.
    var transactionHash: String {
        switch self {
        case .accountCreated(let value):
            return value.transactionHash
        case .payment(let value):
            return value.transactionHash
        }
    }

    var createdAt: Date {
        switch self {
        case .accountCreated(let value):
            return value.createdAt
        case .payment(let value):
            return value.createdAt
        }
    }

    case accountCreated(AccountCreated)
    case payment(Payment)

    /**
     Historical transaction representing the creation of an account.
     See [Stellar Create Account Object](https://developers.stellar.org/api/resources/operations/object/create-account/) for more info.
     */
    struct AccountCreated {

        /// The transaction identifier, used for equality checking and backend calls.
        let identifier: String

        /// The transaction paging token, used for pagination.
        let pagingToken: String

        let funder: String
        let account: String
        let direction: Direction
        let balance: Decimal
        let sourceAccountID: String

        /// The transaction hash, used in Explorer URLs.
        let transactionHash: String

        let createdAt: Date
        var fee: Int?
        var memo: String?
    }

    /**
     Historical transaction representing a payment.
     See [Stellar Payment Object](https://developers.stellar.org/api/resources/operations/object/payment/) for more info.
     */
    struct Payment {

        /// The transaction identifier, used for equality checking and backend calls.
        let identifier: String

        /// The transaction paging token, used for pagination.
        let pagingToken: String

        let fromAccount: String
        let toAccount: String
        let direction: Direction
        let amount: String

        /// The transaction hash, used in Explorer URLs.
        let transactionHash: String

        let createdAt: Date
        var fee: Int?
        var memo: String?
    }
}
