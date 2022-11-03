// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Errors
import Foundation
import ToolKit

public protocol NetworkCommunicatorAPI {

    /// Performs network requests
    /// - Parameter request: the request object describes the network request to be performed
    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError>

    func dataTaskWebSocketPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError>
}

public protocol NetworkDebugLogger {
    func storeRequest(
        _ request: URLRequest,
        response: URLResponse?,
        error: Error?,
        data: Data?,
        metrics: URLSessionTaskMetrics?,
        session: URLSession?
    )
}

final class NetworkCommunicator: NetworkCommunicatorAPI {

    // MARK: - Private properties

    private let session: NetworkSession
    private let authenticator: AuthenticatorAPI?
    private let eventRecorder: AnalyticsEventRecorderAPI?
    private let networkDebugLogger: NetworkDebugLogger

    // MARK: - Setup

    init(
        session: NetworkSession = resolve(),
        sessionDelegate: SessionDelegateAPI = resolve(),
        sessionHandler: NetworkSessionDelegateAPI = resolve(),
        authenticator: AuthenticatorAPI? = nil,
        eventRecorder: AnalyticsEventRecorderAPI? = nil,
        networkDebugLogger: NetworkDebugLogger = resolve()
    ) {
        self.session = session
        self.authenticator = authenticator
        self.eventRecorder = eventRecorder
        self.networkDebugLogger = networkDebugLogger

        sessionDelegate.delegate = sessionHandler
    }

    // MARK: - Internal methods

    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        guard request.authenticated else {
            return execute(request: request)
        }
        guard let authenticator else {
            fatalError("Authenticator missing")
        }
        let _execute = execute
        return authenticator
            .authenticate { [execute = _execute] token in
                execute(request.adding(authenticationToken: token))
            }
    }

    func dataTaskWebSocketPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        guard request.authenticated else {
            return openWebSocket(request: request)
        }
        guard let authenticator else {
            fatalError("Authenticator missing")
        }
        let _executeWebsocketRequest = executeWebsocketRequest
        return authenticator
            .authenticate { [executeWebsocketRequest = _executeWebsocketRequest] token in
                executeWebsocketRequest(request.adding(authenticationToken: token))
            }
    }

    private func openWebSocket(
        request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        session.erasedWebSocketTaskPublisher(
            for: request.peek("🌎", \.urlRequest.cURLCommand, if: \.isDebugging.request).urlRequest
        )
        .mapError { error in
            NetworkError(request: request.urlRequest, type: .urlError(error))
        }
        .flatMap { elements in
            request.responseHandler.handle(message: elements, for: request)
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Private methods

    private func execute(
        request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        session.erasedDataTaskPublisher(
            for: request.peek("🌎", \.urlRequest.cURLCommand, if: \.isDebugging.request).urlRequest
        )
        .handleEvents(
            receiveOutput: { [networkDebugLogger, session] data, response in
                networkDebugLogger.storeRequest(
                    request.urlRequest,
                    response: response,
                    error: nil,
                    data: data,
                    metrics: nil,
                    session: session as? URLSession
                )
            },
            receiveCompletion: { [networkDebugLogger, session] completion in
                guard case .failure(let error) = completion else {
                    return
                }
                networkDebugLogger.storeRequest(
                    request.urlRequest,
                    response: nil,
                    error: error,
                    data: nil,
                    metrics: nil,
                    session: session as? URLSession
                )
            }
        )
        .mapError { error in
            NetworkError(request: request.urlRequest, type: .urlError(error))
        }
        .flatMap { elements -> AnyPublisher<ServerResponse, NetworkError> in
            request.responseHandler.handle(elements: elements, for: request)
        }
        .eraseToAnyPublisher()
        .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
            error.analyticsEvent(for: request) { serverErrorResponse in
                request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
            }
        }
        .eraseToAnyPublisher()
    }

    private func executeWebsocketRequest(
        request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        session.erasedWebSocketTaskPublisher(
            for: request.peek("🌎", \.urlRequest.cURLCommand, if: \.isDebugging.request).urlRequest
        )
        .handleEvents(
            receiveOutput: { [networkDebugLogger, session] _ in
                networkDebugLogger.storeRequest(
                    request.urlRequest,
                    response: nil,
                    error: nil,
                    data: nil,
                    metrics: nil,
                    session: session as? URLSession
                )
            },
            receiveCompletion: { [networkDebugLogger, session] completion in
                guard case .failure(let error) = completion else {
                    return
                }
                networkDebugLogger.storeRequest(
                    request.urlRequest,
                    response: nil,
                    error: error,
                    data: nil,
                    metrics: nil,
                    session: session as? URLSession
                )
            }
        )
        .mapError { error in
            NetworkError(request: request.urlRequest, type: .urlError(error))
        }
        .flatMap { messages -> AnyPublisher<ServerResponse, NetworkError> in
            request.responseHandler.handle(message: messages, for: request)
        }
        .eraseToAnyPublisher()
        .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
            error.analyticsEvent(for: request) { serverErrorResponse in
                request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
            }
        }
        .eraseToAnyPublisher()
    }
}

protocol NetworkSession {
    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError>

    func erasedWebSocketTaskPublisher(
        for request: URLRequest)
        -> AnyPublisher<URLSessionWebSocketTask.Message, URLError>
}

extension URLSession: NetworkSession {
    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
    }

    func erasedWebSocketTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<URLSessionWebSocketTask.Message, URLError> {
        WebSocketTaskPublisher(with: request)
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponse,
    Failure == NetworkError
{

    fileprivate func recordErrors(
        on recorder: AnalyticsEventRecorderAPI?,
        request: NetworkRequest,
        errorMapper: @escaping (NetworkRequest, NetworkError) -> AnalyticsEvent?
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        handleEvents(
            receiveCompletion: { completion in
                guard case .failure(let communicatorError) = completion else {
                    return
                }
                guard let event = errorMapper(request, communicatorError) else {
                    return
                }
                recorder?.record(event: event)
            }
        )
        .eraseToAnyPublisher()
    }
}
