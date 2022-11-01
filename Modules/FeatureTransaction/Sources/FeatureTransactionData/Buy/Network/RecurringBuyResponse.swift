import FeatureTransactionDomain
import Foundation
import MoneyKit
import PlatformKit

struct RecurringBuyResponse: Decodable {
    let id: String
    let userId: String
    let inputCurrency: String
    let inputValue: String
    let destinationCurrency: String
    let paymentMethod: String
    let paymentMethodId: String?
    let period: String
    let nextPayment: String
    let state: String
    let insertedAt: String
    let updatedAt: String
}

extension RecurringBuy {
    init?(_ response: RecurringBuyResponse) {
        guard let paymentMethodType = PaymentMethodPayloadType(rawValue: response.paymentMethod) else { return nil }
        guard let inputCurrency: FiatCurrency = .init(code: response.inputCurrency) else { return nil }
        guard let destinationCurrency: CryptoCurrency = .init(code: response.destinationCurrency) else { return nil }
        self = .init(
            id: response.id,
            state: .init(rawValue: response.state)!,
            recurringBuyFrequency: .init(rawValue: response.period) ?? .unknown,
            nextPaymentDate: DateFormatter.iso8601Format.date(from: response.nextPayment) ?? Date(),
            paymentMethodType: paymentMethodType,
            paymentMethodId: response.paymentMethodId,
            amount: MoneyValue.create(minor: response.inputValue, currency: .fiat(inputCurrency))!,
            asset: .crypto(destinationCurrency),
            createDate: DateFormatter.iso8601Format.date(from: response.insertedAt) ?? Date()
        )
    }
}
