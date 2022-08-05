// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PassKit

public struct ApplePayToken: Codable, Equatable {

    public struct BillingPaymentContact: Codable, Equatable {
        public let line1: String?
        public let line2: String?
        public let city: String?
        public let state: String?
        public let country: String?
        public let postCode: String?
        public let firstname: String?
        public let middleName: String?
        public let lastname: String?
        public let phone: String?
        public let email: String?
    }

    public let paymentData: ApplePayTokenData
    public let paymentMethod: ApplePayPaymentMethod
    public let transactionIdentifier: String
    public var billingPaymentContact: BillingPaymentContact?
    /// This will be removed after debugging it, today
    public var billingPaymentContactMore: BillingPaymentContact?
}

extension ApplePayToken {
    init?(token: PKPaymentToken, billingContact: PKContact?) {
        guard let paymentData = try? JSONDecoder().decode(ApplePayTokenData.self, from: token.paymentData),
              let paymentMethod = ApplePayPaymentMethod(paymentMethod: token.paymentMethod)
        else {
            return nil
        }

        var billingPaymentContact: BillingPaymentContact? {
            guard let billingAddress = billingContact else { return nil }
            let address = billingContact?.postalAddress
            return BillingPaymentContact(
                line1: address?.street,
                line2: address?.subLocality,
                city: address?.city,
                state: address?.state,
                country: address?.country,
                postCode: address?.postalCode,
                firstname: billingAddress.name?.givenName,
                middleName: billingAddress.name?.middleName,
                lastname: billingAddress.name?.familyName,
                phone: billingAddress.phoneNumber?.stringValue,
                email: billingContact?.emailAddress
            )
        }
        var billingPaymentContactMore: BillingPaymentContact? {
            guard let billingAddress = token.paymentMethod.billingAddress else { return nil }
            let address = billingAddress.postalAddresses.first?.value
            let email = billingAddress.emailAddresses.first?.value
            return BillingPaymentContact(
                line1: address?.street,
                line2: address?.subLocality,
                city: address?.city,
                state: address?.state,
                country: address?.country,
                postCode: address?.postalCode,
                firstname: billingAddress.givenName,
                middleName: billingAddress.middleName,
                lastname: billingAddress.familyName,
                phone: billingAddress.phoneNumbers.first?.value.stringValue,
                email: email.map { String($0) }
            )
        }
        self.init(
            paymentData: paymentData,
            paymentMethod: paymentMethod,
            transactionIdentifier: token.transactionIdentifier,
            billingPaymentContact: billingPaymentContact,
            billingPaymentContactMore: billingPaymentContactMore
        )
    }
}
