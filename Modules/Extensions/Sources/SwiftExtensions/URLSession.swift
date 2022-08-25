import Combine
import Foundation

public protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

public protocol URLSessionProtocol {

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol

    func dataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: URLSessionProtocol {

    @_disfavoredOverload
    @inlinable public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
        dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
    }

    @_disfavoredOverload
    @inlinable public func dataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

#if DEBUG

extension URLSessionProtocol {

    public static var test: ImmediateURLSession {
        ImmediateURLSession()
    }
}

public class ImmediateURLSessionDataTask: URLSessionDataTaskProtocol {

    private let closure: () -> Void
    var isCancelled: Bool = false

    public init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    public func resume() { closure() }
    public func cancel() { isCancelled = true }
}

public class ImmediateURLSession: URLSessionProtocol {

    public var data: Data?
    public var error: URLError?

    public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
        let data = data
        let error = error
        return ImmediateURLSessionDataTask {
            completionHandler(data, nil, error)
        }
    }

    public func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        if let error = error {
            return Fail(error: error).eraseToAnyPublisher()
        } else if let data = data {
            return Just((data, request.ok)).setFailureType(to: URLError.self).eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }
}

extension URLRequest {

    public init(_ method: String, _ url: URL) {
        self.init(url: url)
        httpMethod = method
    }

    public var key: MockURLProtocol.Key {
        MockURLProtocol.Key(url: url!, method: httpMethod ?? "GET")
    }

    public var ok: HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    public var err: HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
    }
}

public class MockURLProtocol: URLProtocol {

    public struct Error: Swift.Error {
        let message: String
    }

    public struct Key: Hashable {
        public let url: URL, method: String
    }

    private static var map: [Key: (URLRequest) throws -> (HTTPURLResponse, Data?)] = [:]
    public static func register(_ request: URLRequest, body: @escaping (URLRequest) throws -> (HTTPURLResponse, Data?)) {
        map[request.key] = body
    }

    override public class func canInit(with request: URLRequest) -> Bool { true }
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override public func startLoading() {
        do {
            let (response, data) = try Self.map[request.key].or(
                throw: Error(message: "No value for request")
            )(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override public func stopLoading() {}
}

#endif
