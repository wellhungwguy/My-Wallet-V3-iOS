// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

protocol AuthenticationClientAPI {
    func auth(
        guid: String,
        sharedKeyHash: String
    ) -> AnyPublisher<Void, NetworkError>
}

extension Client: AuthenticationClientAPI {

    private struct AuthRequestPayload: Encodable {
        let guid: String
        let sharedKeyHash: String
    }

    func auth(guid: String, sharedKeyHash: String) -> AnyPublisher<Void, NetworkError> {
        let payload = AuthRequestPayload(guid: guid, sharedKeyHash: sharedKeyHash)
        let request = requestBuilder
            .post(
                path: Endpoint.auth,
                body: try? payload.encode()
            )!

        return networkAdapter
            .perform(request: request)
            .mapToVoid()
    }
}
