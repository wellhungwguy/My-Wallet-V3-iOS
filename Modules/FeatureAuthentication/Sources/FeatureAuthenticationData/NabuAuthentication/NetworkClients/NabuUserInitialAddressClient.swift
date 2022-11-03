// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import NetworkKit

protocol NabuUserResidentialInfoClientAPI {
    func setInitialResidentialInfo(
        country: String,
        state: String?
    ) -> AnyPublisher<Void, NetworkError>
}

final class NabuUserResidentialInfoClient: NabuUserResidentialInfoClientAPI {

    // MARK: - Type

    let initialAddress = ["users", "current", "address", "initial"]

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func setInitialResidentialInfo(
        country: String,
        state: String?
    ) -> AnyPublisher<Void, NetworkError> {
        struct Payload: Encodable {
            let country: String
            let state: String?
        }

        func normalizedState() -> String? {
            guard let state else {
                return nil
            }
            return "\(country)-\(state)".uppercased()
        }

        let payload = Payload(
            country: country.uppercased(),
            state: normalizedState()
        )
        let request = requestBuilder.put(
            path: initialAddress,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
