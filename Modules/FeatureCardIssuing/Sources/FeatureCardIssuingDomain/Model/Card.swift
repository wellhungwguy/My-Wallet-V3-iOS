// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Card: Codable, Equatable, Identifiable {

    public let id: String

    public let type: CardType

    public let last4: String

    /// Expiry date of the card in mm/yy format
    public let expiry: String

    public let brand: Brand

    public let status: Status

    public let orderStatus: [OrderStatus]?

    public let createdAt: String

    public init(
        id: String,
        type: Card.CardType,
        last4: String,
        expiry: String,
        brand: Card.Brand,
        status: Card.Status,
        orderStatus: [Card.OrderStatus]?,
        createdAt: String
    ) {
        self.id = id
        self.type = type
        self.last4 = last4
        self.expiry = expiry
        self.brand = brand
        self.status = status
        self.orderStatus = orderStatus
        self.createdAt = createdAt
    }
}

extension Card {

    public enum CardType: String, Codable {
        case virtual = "VIRTUAL"
        case physical = "PHYSICAL"
    }

    public enum Brand: String, Codable {
        case visa = "VISA"
        case mastercard = "MASTERCARD"
    }

    public enum Status: String, Codable {
        case initiated = "INITIATED"
        case created = "CREATED"
        case active = "ACTIVE"
        case terminated = "TERMINATED"
        case suspended = "SUSPENDED"
        case unsupported = "UNSUPPORTED"
        case unactivated = "UNACTIVATED"
        case limited = "LIMITED"
        case locked = "LOCKED"
    }

    public struct OrderStatus: Codable, Equatable {
        let status: Status
        let date: Date
    }

    public struct Address: Codable, Hashable {

        public enum Constants {
            static let usIsoCode = "US"
            public static let usPrefix = "US-"
        }

        public let line1: String?

        public let line2: String?

        public let city: String?

        public let postCode: String?

        public let state: String?

        /// Country code in ISO-2
        public let country: String?

        public init(
            line1: String?,
            line2: String?,
            city: String?,
            postCode: String?,
            state: String?,
            country: String?
        ) {
            self.line1 = line1
            self.line2 = line2
            self.city = city
            self.postCode = postCode
            self.country = country

            if let state,
               country == Constants.usIsoCode,
               !state.hasPrefix(Constants.usPrefix)
            {
                self.state = Constants.usPrefix + state
            } else {
                self.state = state
            }
        }
    }
}

extension Card.OrderStatus {

    public enum Status: String, Codable {
        case ordered = "ORDERED"
        case shipped = "SHIPPED"
        case delivered = "DELIVERED"
    }
}

extension Card {

    public var creationDate: Date? {
        DateFormatter.iso8601Format.date(from: createdAt)
    }

    public var isLocked: Bool {
        status == .locked
    }
}
