// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import NetworkKit

public final class LegalClient: LegalClientAPI {

    // MARK: - Types

    private enum Path: String {
        case legal
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

    func fetchLegalItems() -> AnyPublisher<[LegalItem], NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.legal.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [LegalItem].self)
            .eraseToAnyPublisher()
    }

    func setAccepted(legalItems: [LegalItem]) -> AnyPublisher<[LegalItem], NabuNetworkError> {
        let request = requestBuilder.put(
            path: [Path.legal.rawValue],
            body: try? legalItems.acceptParameters.encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [LegalItem].self)
            .eraseToAnyPublisher()
    }
}

struct AcceptLegalParameters: Encodable {

    let legalPolicies: [Item]

    struct Item: Encodable {
        let name: String
        let acceptedVersion: Int
    }
}

extension LegalItem {

    var acceptParameters: AcceptLegalParameters.Item {
        AcceptLegalParameters.Item(name: name, acceptedVersion: version)
    }
}

extension Array where Element == LegalItem {

    var acceptParameters: AcceptLegalParameters {
        AcceptLegalParameters(legalPolicies: map(\.acceptParameters))
    }
}
