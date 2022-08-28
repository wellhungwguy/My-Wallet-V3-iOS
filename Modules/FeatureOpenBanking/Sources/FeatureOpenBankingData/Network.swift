// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import DIKit
import Foundation
#if canImport(WalletNetworkKit)
import WalletNetworkKit
typealias RequestBuilderToUse = WalletNetworkKit.RequestBuilder
typealias NetworkRequestToUse = WalletNetworkKit.NetworkRequest
#else
import NetworkKit
typealias RequestBuilderToUse = NetworkKit.RequestBuilder
typealias NetworkRequestToUse = NetworkKit.NetworkRequest
#endif

public protocol Network {
    func perform<ResponseType>(
        request: Request,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, NetworkError> where ResponseType: Decodable

    func perform(
        request: Request
    ) -> AnyPublisher<Void, NetworkError>
}

extension Network {
    public func perform(request: Request) -> AnyPublisher<Void, NetworkError> {
        perform(request: request, responseType: EmptyNetworkResponse.self).mapToVoid()
    }
}

public protocol Request {
    var urlRequest: URLRequest { get }
}

public protocol RequestBuilder {
    func get(
        path: [String],
        authenticated: Bool
    ) -> Request

    func post(
        path: [String],
        body: Data?,
        authenticated: Bool
    ) -> Request

    func delete(
        path: [String],
        authenticated: Bool
    ) -> Request
}

extension RequestBuilder {

    public func get(path: String..., authenticated: Bool = true) -> Request {
        get(path: path, authenticated: authenticated)
    }

    public func post(path: String..., body: Data? = nil, authenticated: Bool = true) -> Request {
        post(path: path, body: body, authenticated: authenticated)
    }

    public func delete(path: [String], authenticated: Bool = true) -> Request {
        delete(path: path, authenticated: authenticated)
    }
}

extension RequestBuilderToUse: RequestBuilder {

    public func get(path: [String], authenticated: Bool) -> Request {
        get(path: path, parameters: nil, authenticated: authenticated)!
    }

    public func post(path: [String], body: Data?, authenticated: Bool) -> Request {
        post(path: path, body: body, authenticated: authenticated)!
    }

    public func delete(path: [String], authenticated: Bool) -> Request {
        delete(path: path, authenticated: authenticated)!
    }
}

extension NetworkRequestToUse: Request {}

extension URLRequest: Request {
    public var urlRequest: URLRequest { self }
}

protocol NetworkRequestConvertible {
    var networkRequest: NetworkRequest { get }
}

struct AnyNetwork<N: NetworkAdapterAPI, R>: Network where R: Request & NetworkRequestConvertible {

    let adapter: N

    init(_ adapter: N, _ requestType: R.Type = R.self) {
        self.adapter = adapter
    }

    func perform<ResponseType>(
        request: R,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, NetworkError> where ResponseType: Decodable {
        adapter.perform(request: request.networkRequest, responseType: ResponseType.self)
    }

    func perform<ResponseType>(
        request: Request, responseType: ResponseType.Type = ResponseType.self
    ) -> AnyPublisher<ResponseType, NetworkError> where ResponseType: Decodable {
        guard let request = request as? R else {
            return Fail(
                error: NetworkError(
                    request: request.urlRequest,
                    type: .urlError(URLError(.badURL))
                )
            )
            .eraseToAnyPublisher()
        }
        return perform(request: request, responseType: ResponseType.self)
    }
}

extension NetworkRequest: NetworkRequestConvertible {
    var networkRequest: NetworkRequest { self }
}

extension NetworkAdapterAPI {
    public var network: Network { AnyNetwork(self, NetworkRequest.self) }
}

#if DEBUG

public struct URLRequestBuilder: RequestBuilder {

    let baseURL: URL
    var headers: [String: String] = [:]
    var authorization: String

    public init(
        baseURL: URL,
        headers: [String: String] = [:],
        authorization: String
    ) {
        self.baseURL = baseURL
        self.headers = headers
        self.authorization = authorization
    }

    public func get(
        path: [String],
        authenticated: Bool
    ) -> Request {
        makeRequest(method: "GET", path: path, authenticated: authenticated)
    }

    public func post(
        path: [String],
        body: Data?,
        authenticated: Bool
    ) -> Request {
        var url = makeRequest(method: "POST", path: path, authenticated: authenticated)
        url.httpBody = body
        return url
    }

    public func delete(
        path: [String],
        authenticated: Bool
    ) -> Request {
        makeRequest(method: "DELETE", path: path, authenticated: authenticated)
    }

    func makeRequest(method: String, path: [String], authenticated: Bool) -> URLRequest {
        var url = URLRequest(
            url: path.reduce(into: baseURL) { url, component in
                url.appendPathComponent(component)
            }
        )
        url.httpMethod = method
        var allHTTPHeaderFields = headers
        if authenticated {
            allHTTPHeaderFields.merge(["Authorization": authorization])
        }
        url.allHTTPHeaderFields = allHTTPHeaderFields
        return url
    }
}

public class OfflineNetwork: Network {

    public typealias Method = String
    public let data: [URL: [Method: Any]]
    public var requests: [URLRequest] = []

    init(_ data: [URL: [Method: Any]]) {
        self.data = data
    }

    public func perform<ResponseType>(
        request: Request,
        responseType: ResponseType.Type = ResponseType.self
    ) -> AnyPublisher<ResponseType, NetworkError> where ResponseType: Decodable {
        requests.append(request.urlRequest)
        guard
            let url = request.urlRequest.url,
            let method = request.urlRequest.httpMethod,
            let value = data[url]?[method]
        else {
            return Fail(
                error: NetworkError(
                    request: request.urlRequest,
                    type: .urlError(URLError(.unsupportedURL))
                )
            )
            .eraseToAnyPublisher()
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
            let object = try JSONDecoder().decode(ResponseType.self, from: data)
            return Just(object).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
        } catch {
            return Fail(
                error: NetworkError(
                    request: request.urlRequest,
                    type: .payloadError(.emptyData)
                )
            )
            .eraseToAnyPublisher()
        }
    }
}

public class SessionNetwork: Network {

    public var session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func perform<ResponseType>(
        request: Request,
        responseType: ResponseType.Type = ResponseType.self
    ) -> AnyPublisher<ResponseType, NetworkError> where ResponseType: Decodable {
        session.dataTaskPublisher(for: request.urlRequest)
            .mapError { error in
                NetworkError(request: request.urlRequest, type: .urlError(error))
            }
            .map(\.data)
            .decode(type: ResponseType.self, decoder: JSONDecoder())
            .mapError { _ in NetworkError(request: request.urlRequest, type: .serverError(.badResponse)) }
            .eraseToAnyPublisher()
    }
}

#endif
