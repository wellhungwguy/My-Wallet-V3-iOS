// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Product: Decodable, Equatable, Identifiable {
    public var id: String {
        productCode
    }

    public var hasRemainingCards: Bool {
        remainingCards > 0
    }

    public let productCode: String

    public let price: Money

    public let brand: Card.Brand

    public let type: Card.CardType

    /// Number of remaining cards that can be created for this product
    public let remainingCards: Int

    public init(
        productCode: String,
        price: Money,
        brand: Card.Brand,
        type: Card.CardType,
        remainingCards: Int
    ) {
        self.productCode = productCode
        self.price = price
        self.brand = brand
        self.type = type
        self.remainingCards = remainingCards
    }
}
