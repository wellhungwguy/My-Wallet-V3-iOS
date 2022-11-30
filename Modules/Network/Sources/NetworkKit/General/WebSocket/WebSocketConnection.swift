// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import Network

public final class WebSocketConnection {
    public enum Event: Equatable {
        case connected
        case disconnected(DisconnectionData)
        case received(Message)
    }

    private let url: URL
    private let handler: (Event) -> Void

    private(set) var isConnected: Bool = false
    private var task: URLSessionWebSocketTask?
    private var pingTimer: Timer?
    private let logger: ((String) -> Void)?

    private lazy var session: URLSession = URLSessionFactory
        .urlSession { [weak self] delegateEvent in
            let event: WebSocketEvent
            switch delegateEvent {
            case .didOpen:
                event = .connected
            case .didClose(let closeCode):
                event = .disconnected(closeCode)
            }
            self?.handleEvent(event)
        }

    init(
        url: URL,
        handler: @escaping (Event) -> Void,
        logger: ((String) -> Void)?
    ) {
        self.url = url
        self.handler = handler
        self.logger = logger
    }

    deinit {
        pingTimer?.invalidate()
        session.invalidateAndCancel()
    }

    func open(_ requestBuilder: (URL) -> URLRequest = { URLRequest(url: $0, timeoutInterval: 30) }) {
        logger?("WebSocketConnection: Open \(url)")
        if task != nil {
            close(closeCode: .normalClosure)
        }
        let urlRequest = requestBuilder(url)
        task = session.webSocketTask(with: urlRequest)
        task?.resume()
        receive()
    }

    func close(closeCode: URLSessionWebSocketTask.CloseCode) {
        pingTimer?.invalidate()
        task?.cancel(with: closeCode, reason: nil)
        task = nil
    }

    func send(_ message: Message) {
        logger?("WebSocketConnection: Send \(message)")
        task?.send(message.sessionMessage) { [weak self, logger] error in
            if let error {
                logger?("WebSocketConnection: Send failed \(message)")
                self?.handleEvent(.connnectionError(.failed(error)))
            } else {
                logger?("WebSocketConnection: Send success \(message)")
            }
        }
    }
}

extension WebSocketConnection {

    private func receive() {
        logger?("WebSocketConnection: Receive Listen")
        task?.receive(completionHandler: { [weak self, logger] result in
            logger?("WebSocketConnection: Receive")
            switch result {
            case .success(let message):
                logger?("WebSocketConnection: Receive Success \(message)")
                switch message {
                case .string(let string):
                    self?.handleEvent(.received(.string(string)))
                case .data(let data):
                    self?.handleEvent(.received(.data(data)))
                @unknown default:
                    // No action
                    break
                }
                self?.receive()
            case .failure(let error):
                logger?("WebSocketConnection: Receive Error \(error)")
                self?.handleEvent(.connnectionError(.failed(error)))
            }
        })
    }

    private func sendPing() {
        guard isConnected else {
            logger?("WebSocketConnection: Ping skip, not connected")
            return
        }
        logger?("WebSocketConnection: Ping")
        task?.sendPing { [weak self, logger] error in
            if let error {
                logger?("WebSocketConnection: Pong error \(error)")
                self?.handleEvent(.connnectionError(.failed(error)))
            } else {
                logger?("WebSocketConnection: Pong")
            }
        }
    }

    private func handleEvent(_ event: WebSocketEvent) {
        switch event {
        case .connected:
            logger?("WebSocketConnection: Handle connected")
            isConnected = true
            DispatchQueue.main.async {
                self.pingTimer = Timer.scheduledTimer(
                    withTimeInterval: 30,
                    repeats: true
                ) { [weak self] _ in
                    self?.sendPing()
                }
            }
            handler(.connected)
        case .disconnected(let closeCode):
            logger?("WebSocketConnection: Handle disconnected \(closeCode)")
            guard isConnected else { break }
            isConnected = false
            pingTimer?.invalidate()
            handler(.disconnected(.closeCode(closeCode)))
        case .received(let message):
            logger?("WebSocketConnection: Handle received \(message)")
            handler(.received(message))
        case .connnectionError(let error):
            logger?("WebSocketConnection: Handle connnectionError \(error)")
            handler(.disconnected(.error(error)))
        }
    }

    public enum WebSocketError: Error, Equatable {
        case failed(Error)

        public static func == (lhs: WebSocketConnection.WebSocketError, rhs: WebSocketConnection.WebSocketError) -> Bool {
            switch (lhs, rhs) {
            case (.failed, .failed):
                return false
            }
        }
    }

    enum WebSocketEvent: Equatable {
        case connected
        case disconnected(URLSessionWebSocketTask.CloseCode)
        case received(Message)
        case connnectionError(WebSocketError)
    }

    public enum Message: Equatable {
        case data(Data)
        case string(String)

        var sessionMessage: URLSessionWebSocketTask.Message {
            switch self {
            case .data(let data):
                return .data(data)
            case .string(let string):
                return .string(string)
            }
        }
    }

    public enum DisconnectionData: Equatable {
        case error(WebSocketError)
        case closeCode(URLSessionWebSocketTask.CloseCode)
    }
}

extension WebSocketConnection {
    enum URLSessionFactory {
        static func urlSession(handler: @escaping (Delegate.Event) -> Void) -> URLSession {
            let delegate = Delegate()
            delegate.handler = handler
            let configuration = URLSessionConfiguration.default
            configuration.shouldUseExtendedBackgroundIdleMode = true
            configuration.waitsForConnectivity = true
            return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        }
    }

    final class Delegate: NSObject, URLSessionWebSocketDelegate {

        enum Event {
            case didOpen
            case didClose(URLSessionWebSocketTask.CloseCode)
        }

        var handler: ((Delegate.Event) -> Void)?

        func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didOpenWithProtocol protocol: String?
        ) {
            handler?(.didOpen)
        }

        func urlSession(
            _ session: URLSession,
            webSocketTask: URLSessionWebSocketTask,
            didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
            reason: Data?
        ) {
            handler?(.didClose(closeCode))
        }
    }
}
