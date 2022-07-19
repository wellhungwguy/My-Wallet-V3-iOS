// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// Needs to be injected from consumer.
public protocol ActivityCardDataServiceAPI {

    /// Stream card display name for the given `paymentMethodId`.
    func fetchCardDisplayName(
        for paymentMethodId: String
    ) -> AnyPublisher<String?, Never>
}
