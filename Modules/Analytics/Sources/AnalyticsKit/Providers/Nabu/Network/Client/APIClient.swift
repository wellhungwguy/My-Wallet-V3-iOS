// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

protocol EventSendingAPI {
    func publish<Events: Encodable>(
        events: Events,
        token: String?
    ) -> AnyPublisher<Never, URLError>
}

final class APIClient: EventSendingAPI {

    // MARK: - Types

    private enum Path {
        static let publishEvents = "/events/publish"
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilderAPI
    private let networkAdapter: NetworkAdapterAPI
    private let jsonEncoder: JSONEncoder

    // MARK: - Setup

    convenience init(basePath: String, userAgent: String) {
        self.init(requestBuilder: RequestBuilder(basePath: basePath, userAgent: userAgent))
    }

    init(
        networkAdapter: NetworkAdapterAPI = NetworkAdapter(),
        requestBuilder: RequestBuilderAPI,
        jsonEncoder: JSONEncoder = {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            return jsonEncoder
        }()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.jsonEncoder = jsonEncoder
    }

    // MARK: - Methods

    func publish(
        events: some Encodable,
        token: String?
    ) -> AnyPublisher<Never, URLError> {
        var headers = [String: String]()
        if let token {
            headers["Authorization"] = "Bearer \(token)"
        }
        let request = requestBuilder.post(
            path: Path.publishEvents,
            body: try? jsonEncoder.encode(events),
            headers: headers
        )
        return networkAdapter.performRequest(request: request)
    }
}
