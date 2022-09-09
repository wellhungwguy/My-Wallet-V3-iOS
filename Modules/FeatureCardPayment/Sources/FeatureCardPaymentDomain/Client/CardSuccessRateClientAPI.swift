// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol CardSuccessRateClientAPI: AnyObject {

    /// When a user attempts to add a new card, or use an existing card,
    /// information will be shared with clients to display failure rates of their institution
    /// so that the user can be directed to an alternative payment method.
    /// This API returns a `CardSuccessRateResponse` based on a six digit bin number.
    func getCardSuccessRate(binNumber: String) -> AnyPublisher<CardSuccessRate.Response, NabuNetworkError>
}
