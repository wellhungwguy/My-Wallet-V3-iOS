// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

protocol NabuAnalyticsEventsRepositoryAPI {
    func publish<Events: Encodable>(
        events: Events
    ) -> AnyPublisher<Never, URLError>
}

final class NabuAnalyticsEventsRepository: NabuAnalyticsEventsRepositoryAPI {

    // MARK: - Private properties

    private let client: EventSendingAPI
    private let tokenProvider: TokenProvider

    // MARK: - Setup

    init(
        client: EventSendingAPI,
        tokenProvider: @escaping TokenProvider
    ) {
        self.client = client
        self.tokenProvider = tokenProvider
    }

    // MARK: - AnalyticsEventsRepositoryAPI

    func publish(
        events: some Encodable
    ) -> AnyPublisher<Never, URLError> {
        client
            .publish(events: events, token: tokenProvider())
            .eraseToAnyPublisher()
    }
}
