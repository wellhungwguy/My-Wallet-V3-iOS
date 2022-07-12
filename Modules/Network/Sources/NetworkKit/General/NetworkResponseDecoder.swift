// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Errors
import Foundation
import ToolKit

public protocol NetworkResponseDecoderAPI {

    func decodeOptional<ResponseType: Decodable>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, NetworkError>

    func decodeOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, ErrorResponseType>

    func decode<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, ErrorResponseType>

    func decode<ResponseType: Decodable>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, NetworkError>

    func decode<ErrorResponseType: FromNetworkErrorConvertible>(
        error: NetworkError,
        for request: NetworkRequest
    ) -> ErrorResponseType

    func decodeFailureToString(errorResponse: ServerErrorResponse) -> String?
}

public final class NetworkResponseDecoder: NetworkResponseDecoderAPI {

    // MARK: - Properties

    public static let defaultJSONDecoder: () -> JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    private let makeJSONDecoder: () -> JSONDecoder

    // MARK: - Setup

    public init(_ makeJSONDecoder: @escaping () -> JSONDecoder = NetworkResponseDecoder.defaultJSONDecoder) {
        self.makeJSONDecoder = makeJSONDecoder
    }

    // MARK: - NetworkResponseDecoderAPI

    public func decodeOptional<ResponseType: Decodable>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, NetworkError> {
        decode(
            response: response,
            for: request,
            emptyPayloadHandler: { serverResponse in
                guard serverResponse.response?.statusCode == 204 else {
                    return .failure(
                        NetworkError(
                            request: request.urlRequest,
                            type: .payloadError(.emptyData, response: serverResponse.response)
                        )
                    )
                }
                return .success(nil)
            }
        )
    }

    public func decodeOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        response: ServerResponse,
        responseType: ResponseType.Type,
        for request: NetworkRequest
    ) -> Result<ResponseType?, ErrorResponseType> {
        decode(
            response: response,
            for: request,
            emptyPayloadHandler: { serverResponse in
                guard serverResponse.response?.statusCode == 204 else {
                    return .failure(
                        NetworkError(
                            request: request.urlRequest,
                            type: .payloadError(.emptyData, response: serverResponse.response)
                        )
                    )
                }
                return .success(nil)
            }
        )
        .mapError(ErrorResponseType.from)
    }

    public func decode<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, ErrorResponseType> {
        decode(response: response, for: request)
            .mapError(ErrorResponseType.from)
    }

    public func decode<ResponseType: Decodable>(
        response: ServerResponse,
        for request: NetworkRequest
    ) -> Result<ResponseType, NetworkError> {
        decode(
            response: response,
            for: request,
            emptyPayloadHandler: { serverResponse in
                .failure(
                    NetworkError(
                        request: request.urlRequest,
                        type: .payloadError(.emptyData, response: serverResponse.response)
                    )
                )
            }
        )
    }

    public func decode<ErrorResponseType: FromNetworkErrorConvertible>(
        error: NetworkError,
        for request: NetworkRequest
    ) -> ErrorResponseType {
        guard let payload = error.payload else {
            return ErrorResponseType.from(error)
        }
        let errorResponse: ErrorResponseType
        do {
            let decoder = makeJSONDecoder()
            decoder.userInfo[.networkURLRequest] = request.urlRequest
            decoder.userInfo[.networkHTTPResponse] = error.response
            errorResponse = try decoder.decode(ErrorResponseType.self, from: payload)
        } catch _ {
            return ErrorResponseType.from(error)
        }
        return errorResponse
    }

    public func decodeFailureToString(errorResponse: ServerErrorResponse) -> String? {
        guard let payload = errorResponse.payload else {
            return nil
        }
        return String(data: payload, encoding: .utf8)
    }

    // MARK: - Private methods

    private func decode<ResponseType: Decodable>(
        response: ServerResponse,
        for request: NetworkRequest,
        emptyPayloadHandler: (ServerResponse) -> Result<ResponseType, NetworkError>
    ) -> Result<ResponseType, NetworkError> {
        guard ResponseType.self != EmptyNetworkResponse.self else {
            let emptyResponse: ResponseType = EmptyNetworkResponse() as! ResponseType
            return .success(emptyResponse)
        }
        guard let payload = response.payload else {
            return emptyPayloadHandler(response)
        }
        guard ResponseType.self != RawServerResponse.self else {
            let message = String(data: payload, encoding: .utf8) ?? ""
            let rawResponse = RawServerResponse(data: message) as! ResponseType
            return .success(rawResponse)
        }
        guard ResponseType.self != String.self else {
            let message = String(data: payload, encoding: .utf8) ?? ""
            return .success(message as! ResponseType)
        }
        let decoder = makeJSONDecoder()
        decoder.userInfo[.networkURLRequest] = request.urlRequest
        decoder.userInfo[.networkHTTPResponse] = response.response
        return Result { try decoder.decode(ResponseType.self, from: payload) }
            .flatMapError { decodingError -> Result<ResponseType, NetworkError> in
                let rawPayload = String(data: payload, encoding: .utf8) ?? ""
                let errorMessage = debugErrorMessage(
                    for: decodingError,
                    response: response.response,
                    responseType: ResponseType.self,
                    request: request,
                    rawPayload: rawPayload
                )
                Logger.shared.error(errorMessage)
                // TODO: Fix decoding errors then uncomment this: IOS-4501
                // if BuildFlag.isInternal {
                //     fatalError(errorMessage)
                // }
                return .failure(
                    NetworkError(
                        request: request.urlRequest,
                        type: .payloadError(.badData(rawPayload: rawPayload), response: response.response)
                    )
                )
            }
    }

    private func debugErrorMessage<ResponseType: Decodable>(
        for decodingError: Error,
        response: HTTPURLResponse?,
        responseType: ResponseType.Type,
        request: NetworkRequest,
        rawPayload: String
    ) -> String {
        """
        \n----------------------
        Payload decoding error.
          Error: '\(String(describing: ResponseType.self))': \(decodingError).
            URL: \(response?.url?.absoluteString ?? ""),
        Request: \(request),
        Payload: \(rawPayload)
        ======================\n
        """
    }
}

extension CodingUserInfoKey {
    public static let networkURLRequest = CodingUserInfoKey(rawValue: "com.blockchain.network.url.request")!
    public static let networkHTTPResponse = CodingUserInfoKey(rawValue: "com.blockchain.network.http.response")!
}
