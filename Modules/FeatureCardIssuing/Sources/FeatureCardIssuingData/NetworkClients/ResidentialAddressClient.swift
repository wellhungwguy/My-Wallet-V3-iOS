// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import NetworkKit

public final class ResidentialAddressClient: ResidentialAddressClientAPI {

    // MARK: - Types

    private enum Path: String {
        case residentialAddress = "residential-address"
    }

    struct Parameters: Encodable {
        let address: Card.Address
    }

    struct Response: Decodable {
        let address: Card.Address
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - API

    func fetchResidentialAddress() -> AnyPublisher<Card.Address, NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.residentialAddress.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Response.self)
            .map(\.address)
            .eraseToAnyPublisher()
    }

    func update(residentialAddress: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError> {
        let request = requestBuilder.put(
            path: [Path.residentialAddress.rawValue],
            body: try? Parameters(address: residentialAddress).encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: UpdateAddressRepsponse.self)
            .map { $0.address }
            .eraseToAnyPublisher()
    }
}

private struct UpdateAddressRepsponse: Decodable {
    let address: Card.Address
}
