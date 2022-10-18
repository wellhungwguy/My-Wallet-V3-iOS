// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

public let HTTPHeaderTag = "HTTPHeaderTag"

public struct RequestBuilderQueryParameters {

    public var publisher: AnyPublisher<[URLQueryItem]?, Never>

    public init<P: Publisher>(_ publisher: P) where P.Output == [URLQueryItem]?, P.Failure == Never {
        self.publisher = publisher.eraseToAnyPublisher()
    }
}

public class RequestBuilder {

    public enum Error: Swift.Error {
        case buildingRequest
    }

    private var defaultComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = networkConfig.apiScheme
        urlComponents.host = networkConfig.apiHost
        urlComponents.path = RequestBuilder.path(from: networkConfig.pathComponents)
        return urlComponents
    }

    private let networkConfig: Network.Config
    private let decoder: NetworkResponseDecoderAPI
    private let headers: () -> HTTPHeaders

    private var queryParameters: [URLQueryItem]?
    private var subscription: AnyCancellable?

    public convenience init(
        config: Network.Config = resolve(),
        decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(),
        headers: HTTPHeaders = [:],
        queryParameters: RequestBuilderQueryParameters = .init(Just(nil))
    ) {
        self.init(config: config, decoder: decoder, resolveHeaders: { headers }, queryParameters: queryParameters)
    }

    public init(
        config: Network.Config = resolve(),
        decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(),
        resolveHeaders headers: @escaping () -> HTTPHeaders,
        queryParameters: RequestBuilderQueryParameters = .init(Just(nil))
    ) {
        networkConfig = config
        self.decoder = decoder
        self.headers = headers
        if BuildFlag.isInternal {
            subscription = queryParameters.publisher.sink { [weak self] parameters in
                self?.queryParameters = parameters
            }
        }
    }

    // MARK: - GET

    public func get(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        get(
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func get(
        path: String,
        parameters: [URLQueryItem]? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            method: .get,
            path: path,
            parameters: parameters,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - PUT

    public func put(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        put(
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func put(
        path: String,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            method: .put,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - POST

    public func post(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        post(
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func post(
        path: String,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            method: .post,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - Delete

    public func delete(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            method: .delete,
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - Utilities

    public static func body(from parameters: [URLQueryItem]) -> Data? {
        var components = URLComponents()
        components.queryItems = parameters
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.percentEncodedQuery?.data(using: .utf8)
    }

    // MARK: - Private methods

    private static func path(from components: [String] = []) -> String {
        components.reduce(into: "") { path, component in
            path += "/\(component)"
        }
    }

    private func buildRequest(
        method: NetworkRequest.NetworkMethod,
        path: String,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI?,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        guard let url = buildURL(path: path, parameters: parameters) else {
            return nil
        }
        return NetworkRequest(
            endpoint: url,
            method: method,
            body: body,
            headers: self.headers().merging(headers),
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder ?? self.decoder,
            recordErrors: recordErrors
        )
    }

    private func buildURL(path: String, parameters: [URLQueryItem]? = nil) -> URL? {
        var components = defaultComponents
        components.path += path
        if let parameters {
            components.queryItems = parameters
        }
        if let parameters = queryParameters {
            components.queryItems = components.queryItems.map { $0 + parameters } ?? parameters
        }
        return components.url
    }
}
