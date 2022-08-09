// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol CardSuccessRateServiceAPI: AnyObject {
    /// When a user attempts to add a new card, or use an existing card,
    /// information will be shared with clients to display failure rates of their institution
    /// so that the user can be directed to an alternative payment method.
    /// This API returns a `CardSuccessRateData` based on a six digit bin number.
    /// - Returns: A `Combine.Publisher` that publishes a `CardSuccessRateData` if success or `CardSuccessRateServiceError` if failed.
    func getCardSuccessRate(
        binNumber: String
    ) -> AnyPublisher<CardSuccessRateData, CardSuccessRateServiceError>
}

public enum CardSuccessRateServiceError: Error {
    case nabu(NabuNetworkError)
}
