// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import NetworkKit

public final class TransactionClient: TransactionClientAPI {

    // MARK: - Types

    private enum Path: String {
        case transactions
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

    func fetchTransactions(
        _ params: TransactionsParams?
    ) -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.transactions.rawValue],
            parameters: params?.urlQueryItems,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [Card.Transaction].self)
            .eraseToAnyPublisher()
    }
}

extension TransactionsParams {

    var urlQueryItems: [URLQueryItem] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.formUnion([.withFractionalSeconds])

        var params: [URLQueryItem] = []
        params.append(.init(name: CodingKeys.cardId.rawValue, value: cardId))
        params.append(.init(
            name: CodingKeys.types.rawValue,
            value: try? types?
                .map(\.rawValue)
                .encodeToString(encoding: .utf8)
        ))
        params.append(.init(name: CodingKeys.toId.rawValue, value: toId))
        params.append(.init(name: CodingKeys.fromId.rawValue, value: fromId))

        if let limit {
            params.append(.init(name: CodingKeys.limit.rawValue, value: "\(limit)"))
        }

        if let fromDate = from {
            params.append(.init(name: CodingKeys.from.rawValue, value: formatter.string(from: fromDate)))
        }

        if let toDate = to {
            params.append(.init(name: CodingKeys.to.rawValue, value: formatter.string(from: toDate)))
        }

        return params.filter(\.value.isNotNilOrEmpty)
    }
}
