// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

/// Responsible for networking
public final class PinClient: PinClientAPI {

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let apiURL = URL(string: BlockchainAPI.shared.pinStore)!

    // MARK: - Setup

    public init(networkAdapter: NetworkAdapterAPI = resolve()) {
        self.networkAdapter = networkAdapter
    }

    /// Creates a new pin in the remote pin store
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: a Single returning the response
    public func create(
        pinPayload: PinPayload
    ) -> AnyPublisher<PinStoreResponse, PinStoreResponse> {
        let requestPayload = StoreRequestData(
            payload: pinPayload,
            requestType: .create
        )
        let parameters = requestPayload.dictionary
            .map(URLQueryItem.init)
        let data = RequestBuilder.body(from: parameters)
        let request = NetworkRequest(
            endpoint: apiURL,
            method: .post,
            body: data,
            contentType: .formUrlEncoded
        )
        return networkAdapter.perform(request: request)
    }

    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: an Single returning the response
    public func validate(
        pinPayload: PinPayload
    ) -> AnyPublisher<PinStoreResponse, PinStoreResponse> {
        let requestPayload = StoreRequestData(
            payload: pinPayload,
            requestType: .validate
        )
        let parameters = requestPayload.dictionary
            .map(URLQueryItem.init)
        let data = RequestBuilder.body(from: parameters)
        let request = NetworkRequest(
            endpoint: apiURL,
            method: .post,
            body: data,
            contentType: .formUrlEncoded
        )
        return networkAdapter.perform(request: request)
    }
}

// MARK: - StoreRequestData

extension PinClient {

    struct StoreRequestData {

        // MARK: - Types

        /// The type of the request. this is a weird legacy -
        /// we send the type of the request as a parameter (!?)
        /// instead of just using `HTTPMethod`
        enum RequestType: String, Encodable {
            enum CodingKeys: CodingKey {
                case create
                case validate
            }

            case create = "put"
            case validate = "get"
        }

        enum CodingKeys: String, CodingKey {
            case format
            case pin
            case key
            case value
            case apiCode = "api_code"
            case requestType = "method"
        }

        // MARK: - Properties

        var dictionary: [String: String?] {
            [
                CodingKeys.format.rawValue: format,
                CodingKeys.apiCode.rawValue: apiCode,
                CodingKeys.pin.rawValue: pin,
                CodingKeys.key.rawValue: key,
                CodingKeys.value.rawValue: value,
                CodingKeys.requestType.rawValue: requestType
            ]
        }

        let format = "json"
        let apiCode = BlockchainAPI.Parameters.apiCode
        let pin: String
        let key: String
        let value: String?
        let requestType: String

        // MARK: - Setup

        init(payload: PinPayload, requestType: RequestType) {
            self.pin = payload.pinCode
            self.key = payload.pinKey
            self.value = payload.pinValue
            self.requestType = requestType.rawValue
        }
    }
}
