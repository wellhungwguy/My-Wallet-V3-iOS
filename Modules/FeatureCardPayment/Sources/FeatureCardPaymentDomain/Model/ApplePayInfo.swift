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

    //https://developer.apple.com/documentation/apple_pay_on_the_web/applepaypaymentrequest/2216120-requiredbillingcontactfields
    public let requiredBillingContactFields: [String]?

    /// https://developer.apple.com/documentation/apple_pay_on_the_web/applepaypaymentrequest/2928612-supportedcountries
    public let supportedCountries: [String]?

    /// https://developer.apple.com/documentation/apple_pay_on_the_web/applepaypaymentrequest/1916122-supportednetworks
    public let supportedNetworks: [String]?
}
