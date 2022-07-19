// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct ApplePayInfo: Codable, Equatable {

    /// Name of the acquirer (ie: CHECKOUTDOTCOM, STRIPE)
    public let cardAcquirerName: CardPayload.Acquirer

    /// ISO code of our bank country (GB)
    public let merchantBankCountryCode: String

    /// Publishable Key for the acquirer SDK
    public let publishableApiKey: String?

    /// ID of the payment method
    public let paymentMethodID: String?

    /// Merchant ID for Apple Pay. It changes depending on the acquirer
    public let applePayMerchantID: String

    /// Beneficiary ID to confirm the order
    public let beneficiaryID: String

    /// Enable the credit cards
    public let allowCreditCards: Bool?

    /// Enable the prepaid cards if doable
    public let allowPrepaidCards: Bool?
}
