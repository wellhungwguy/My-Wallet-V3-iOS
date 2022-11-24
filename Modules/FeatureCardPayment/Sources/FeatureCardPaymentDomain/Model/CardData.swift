// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Foundation
import MoneyKit

public struct CardData {
    public init(
        identifier: String,
        state: CardPayload.State,
        partner: CardPayload.Partner,
        type: CardType,
        currency: FiatCurrency?,
        label: String,
        ownerName: String,
        number: String,
        month: String,
        year: String,
        cvv: String,
        topLimit: FiatValue,
        block: Bool = false,
        billingAddress: BillingAddress? = nil,
        lastError: String? = nil,
        ux: UX.Dialog? = nil
    ) {
        self.identifier = identifier
        self.state = state
        self.partner = partner
        self.type = type
        self.currency = currency
        self.label = label
        self.ownerName = ownerName
        self.number = number
        self.month = month
        self.year = year
        self.cvv = cvv
        self.topLimit = topLimit
        self.billingAddress = billingAddress
        self.lastError = lastError
        self.block = block
        self.ux = ux
    }

    /// The identifier of the card
    public let identifier: String

    /// The state of the card
    public let state: CardPayload.State

    /// The partner for the card
    public let partner: CardPayload.Partner

    /// The type of the card (provider)
    public let type: CardType

    /// The currency of the card
    public let currency: FiatCurrency!

    /// The label of the card
    public let label: String

    /// The owner name
    public let ownerName: String

    /// The number on the card
    public let number: String

    /// The month on which the card becomes expired
    public let month: String

    /// The year on which the card becomes expired
    public let year: String

    /// The card verification value
    public let cvv: String

    /// The card's limit
    public var topLimit: FiatValue

    /// The billing address associated with the card
    public var billingAddress: BillingAddress!

    // Error
    public let lastError: String?

    // Error which should be displayed
    public let ux: UX.Dialog?

    // Whether or not the card should be blocked from
    // being used as a payment method
    public let block: Bool

    public func data(byAppending billingAddress: BillingAddress) -> CardData {
        var data = self
        data.billingAddress = billingAddress
        return data
    }

    public var topLimitDisplayValue: String {
        topLimit.displayString
    }

    public var suffix: String {
        "\(number.suffix(4))"
    }

    public var displayExpirationDate: String {
        "\(month)/\(year.suffix(2))"
    }

    public var displaySuffix: String {
        "•••• \(suffix)"
    }

    public var displayLabel: String {
        "\(type.name) \(displaySuffix)"
    }
}

// MARK: - Response Setup

extension CardData {

    public init?(response: CardPayload?) {
        guard let response else { return nil }
        guard let currency = FiatCurrency(code: response.currency) else { return nil }
        guard let billingAddress = response.address else { return nil }
        guard response.partner.isKnown else { return nil }

        self.type = CardType(rawValue: response.card?.type ?? "") ?? .unknown
        self.identifier = response.identifier
        self.ownerName = ""
        self.number = response.card?.number ?? ""
        if let label = response.card?.label, !label.isEmpty {
            self.label = label
        } else {
            self.label = type.name
        }
        self.month = response.card?.month ?? ""
        self.year = response.card?.year ?? ""
        self.cvv = ""

        self.topLimit = .zero(currency: currency)
        self.state = response.state
        self.currency = currency
        self.partner = response.partner
        self.billingAddress = BillingAddress(response: billingAddress)
        self.block = response.block
        self.ux = response.ux
        self.lastError = response.lastError
    }
}

// MARK: - Equatable

extension CardData: Equatable {
    public static func == (lhs: CardData, rhs: CardData) -> Bool {
        lhs.identifier == rhs.identifier &&
            lhs.state == rhs.state
    }
}

// MARK: - Input Setup

extension CardData {

    /// Initializer that setup the `CardData` from user input
    /// - Parameters:
    ///   - ownerName: The name on the card
    ///   - number: The number of the card
    ///   - expirationDate: The expiration date in the format: MM/yy
    ///   - cvv: The cvv on the back of the card
    public init?(
        ownerName: String?,
        number: String?,
        expirationDate: String?,
        cvv: String?
    ) {
        guard let ownerName,
              var number,
              let expirationDate,
              let cvv
        else {
            return nil
        }

        let dateComponents = expirationDate.split(separator: "/")
        guard dateComponents.count == 2 else { return nil }

        self.ownerName = ownerName

        number.removeAll { CharacterSet.whitespaces.contains($0) }
        self.number = number

        self.month = String(dateComponents[0])

        self.year = "20\(dateComponents[1])"
        self.cvv = cvv

        self.type = CardType.determineType(from: number)

        self.state = .none
        self.partner = .unknown
        self.currency = nil
        self.label = "\(type.name) \(number.suffix(4))"
        self.identifier = ""
        self.topLimit = .zero(currency: .USD)
        self.ux = nil
        self.block = false
        self.lastError = nil
    }
}

// MARK: - Array Setup

extension [CardData] {
    init(response: [CardPayload]) {
        self.init()
        let data = response.compactMap { CardData(response: $0) }
        append(contentsOf: data)
    }
}

extension CardData {
    public static let maxCardCount = 5
}
