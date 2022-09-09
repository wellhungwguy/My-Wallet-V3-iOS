import Combine
import FeatureCardPaymentDomain
import Foundation

public final class CardSuccessRateServiceAPIMock: CardSuccessRateServiceAPI {

    public init() {}

    public func getCardSuccessRate(
        binNumber: String
    ) -> AnyPublisher<CardSuccessRateData, CardSuccessRateServiceError> {
        .just(CardSuccessRateData(block: false, bin: "12345678"))
    }
}
