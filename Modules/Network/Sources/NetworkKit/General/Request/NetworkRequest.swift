// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnyCoding
import DIKit
import Foundation

public typealias HTTPHeaders = [String: String]
private var sessionId = UUID()

public struct NetworkRequest {

    public enum NetworkMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    public enum ContentType: String {
        case json = "application/json"
        case formUrlEncoded = "application/x-www-form-urlencoded"
    }

    public var urlRequest: URLRequest {
//        if authenticated, headers[HttpHeaderField.authorization] == nil {
//            fatalError("Missing Authentication Header")
//        }

        var request = URLRequest(
            url: endpoint,
            cachePolicy: allowsCachingResponse ? .useProtocolCachePolicy : .reloadIgnoringLocalCacheData,
            timeoutInterval: timeoutInterval
        )

        request.httpMethod = method.rawValue
        let requestHeaders = headers.merging(defaultHeaders)
        for (key, value) in requestHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }

        if request.value(forHTTPHeaderField: HttpHeaderField.accept) == nil {
            request.addValue(
                HttpHeaderValue.json,
                forHTTPHeaderField: HttpHeaderField.accept
            )
        }
        if request.value(forHTTPHeaderField: HttpHeaderField.contentType) == nil {
            request.addValue(
                contentType.rawValue,
                forHTTPHeaderField: HttpHeaderField.contentType
            )
        }

        addHttpBody(to: &request)

        return request
    }

    public let method: NetworkMethod
    public let endpoint: URL
    public private(set) var headers: HTTPHeaders
    public let contentType: ContentType
    var decoder: NetworkResponseDecoderAPI
    let responseHandler: NetworkResponseHandlerAPI

    /// Defaults to `true` for `GET` requests
    public var allowsCachingResponse: Bool

    public var timeoutInterval: TimeInterval = 30

    // TODO: modify this to be an Encodable type so that JSON serialization is done in this class
    // vs. having to serialize outside of this class
    let body: Data?

    let recordErrors: Bool

    let authenticated: Bool

    let requestId = UUID()

    private(set) var isDebugging = (
        request: ProcessInfo.processInfo.environment["BLOCKCHAIN_DEBUG_NETWORK_REQUEST"] == "TRUE",
        response: ProcessInfo.processInfo.environment["BLOCKCHAIN_DEBUG_NETWORK_RESPONSE"] == "TRUE"
    )

    private var acceptLanguage: [String] {
        Array(Locale.preferredLanguages.prefix(3) + Bundle.main.preferredLocalizations)
    }

    private var defaultHeaders: HTTPHeaders {
        [
            HttpHeaderField.requestId: requestId.uuidString,
            HttpHeaderField.sessionId: sessionId.uuidString,
            HttpHeaderField.acceptLanguage: Set(acceptLanguage).sorted(like: acceptLanguage).qualityEncoded()
        ]
    }

    public init(
        endpoint: URL,
        method: NetworkMethod,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: ContentType = .json,
        decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(),
        responseHandler: NetworkResponseHandlerAPI = NetworkResponseHandler(),
        recordErrors: Bool = false
    ) {
        self.endpoint = endpoint
        self.method = method
        self.body = body
        self.headers = headers
        self.authenticated = authenticated
        self.contentType = contentType
        self.decoder = decoder
        self.responseHandler = responseHandler
        self.recordErrors = recordErrors
        allowsCachingResponse = method == .get
    }

    func adding(authenticationToken: String) -> Self {
        var request = self
        request.headers[HttpHeaderField.authorization] = authenticationToken
        return request
    }

    public func decodingAnyJSON(using decoder: @escaping () -> AnyDecoderProtocol) -> Self {
        var request = self
        request.decoder = NetworkResponseDecoder(.any(decoder))
        return request
    }

    public func decodingAnyJSON(using decoder: AnyDecoderProtocol = AnyDecoder()) -> Self {
        decodingAnyJSON(using: { decoder })
    }

    /// Used by the handler to print debug detailed information about the request and response
    public func debug() -> Self {
        var request = self
        request.isDebugging = (request: true, response: true)
        return request
    }

    private func addHttpBody(to request: inout URLRequest) {
        guard let data = body else {
            return
        }

        switch contentType {
        case .json:
            request.httpBody = data
        case .formUrlEncoded:
            if let params = try? JSONDecoder().decode([String: String].self, from: data) {
                request.encode(params: params)
            } else {
                request.httpBody = data
            }
        }
    }
}

extension NetworkRequest: CustomStringConvertible {

    public var description: String {
        "\(method.rawValue) \(endpoint) (\(authenticated ? "authenticated" : "unauthenticated"))"
    }

    public var bodyDescription: String? {
        guard let data = body,
              let description = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return description
    }
}

extension NetworkRequest: Hashable {

    public static func == (lhs: NetworkRequest, rhs: NetworkRequest) -> Bool {
        // NOTE: Can't compare urlRequests directly because each request's headers object contains a unique ID T_T
        lhs.endpoint == rhs.endpoint && lhs.method == rhs.method && lhs.body == rhs.body
    }

    public func hash(into hasher: inout Hasher) {
        // NOTE: Can't hash urlRequests directly because each request's headers object contains a unique ID T_T
        hasher.combine(endpoint)
        hasher.combine(method)
        hasher.combine(body)
    }
}

extension URLRequest {

    public mutating func encode(params: [String: String]) {
        let encodedParamsArray = params.map { keyPair -> String in
            let (key, value) = keyPair
            return "\(key)=\(percentEscapeString(value))"
        }
        httpBody = encodedParamsArray.joined(separator: "&").data(using: .utf8)
    }

    private func percentEscapeString(_ stringToEscape: String) -> String {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._* ")
        return stringToEscape
            .addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)?
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil) ?? stringToEscape
    }
}

extension Collection where Element == String {

    func qualityEncoded() -> String {
        enumerated()
            .map { index, encoding in
                let quality = 1.0 - (Double(index) * 0.1)
                return "\(encoding);q=\(quality)"
            }
            .joined(separator: ", ")
    }
}
