// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Card {

    public struct Transaction: Identifiable, Equatable {

        public enum State: String, Decodable {
            case pending = "PENDING"
            case cancelled = "CANCELLED"
            case declined = "DECLINED"
            case completed = "COMPLETED"
            case created = "CREATED"
        }

        public enum TransactionType: String, Decodable {
            case payment = "PAYMENT"
            case paymentWithCashback = "PAYMENT_WITH_CASHBACK"
            case atmWithdrawal = "ATM_WITHDRAWAL"
            case chargeback = "CHARGEBACK"
            case funding = "FUNDING"
            case refund = "REFUND"
        }

        enum CodingKeys: String, CodingKey {
            case id
            case cardId
            case transactionType = "type"
            case state
            case originalAmount
            case fundingAmount
            case reversedAmount
            case counterAmount
            case clearedFundingAmount
            case userTransactionTime
            case merchantName
            case networkConversionRate
            case declineReason
            case fee
        }

        public let id: String
        public let cardId: String
        public let transactionType: TransactionType
        public let state: State
        public let originalAmount: Money
        public let fundingAmount: Money
        public let reversedAmount: Money
        public let counterAmount: Money?
        public let clearedFundingAmount: Money
        public let userTransactionTime: Date
        public let merchantName: String
        public let networkConversionRate: Double?
        public let declineReason: String?
        public let fee: Money

        public init(
            id: String,
            cardId: String,
            type: TransactionType,
            state: State,
            originalAmount: Money,
            fundingAmount: Money,
            reversedAmount: Money,
            counterAmount: Money? = nil,
            clearedFundingAmount: Money,
            userTransactionTime: Date,
            merchantName: String,
            networkConversionRate: Double? = nil,
            declineReason: String? = nil,
            fee: Money
        ) {
            self.id = id
            self.cardId = cardId
            transactionType = type
            self.state = state
            self.originalAmount = originalAmount
            self.fundingAmount = fundingAmount
            self.reversedAmount = reversedAmount
            self.counterAmount = counterAmount
            self.clearedFundingAmount = clearedFundingAmount
            self.userTransactionTime = userTransactionTime
            self.merchantName = merchantName
            self.networkConversionRate = networkConversionRate
            self.declineReason = declineReason
            self.fee = fee
        }
    }
}

extension Card.Transaction: Decodable {

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(String.self, forKey: .id)
        cardId = try values.decode(String.self, forKey: .cardId)
        transactionType = try values.decode(TransactionType.self, forKey: .transactionType)
        state = try values.decode(State.self, forKey: .state)
        originalAmount = try values.decode(Money.self, forKey: .originalAmount)
        fundingAmount = try values.decode(Money.self, forKey: .fundingAmount)
        reversedAmount = try values.decode(Money.self, forKey: .reversedAmount)
        counterAmount = try values.decodeIfPresent(Money.self, forKey: .counterAmount)
        clearedFundingAmount = try values.decode(Money.self, forKey: .clearedFundingAmount)
        let transaction = try values.decode(String.self, forKey: .userTransactionTime)
        userTransactionTime = ISO8601DateFormatter().date(from: transaction) ?? Date()
        merchantName = try values.decode(String.self, forKey: .merchantName)
        networkConversionRate = try values.decodeIfPresent(Double.self, forKey: .networkConversionRate)
        declineReason = try values.decodeIfPresent(String.self, forKey: .declineReason)
        fee = try values.decode(Money.self, forKey: .fee)
    }
}
