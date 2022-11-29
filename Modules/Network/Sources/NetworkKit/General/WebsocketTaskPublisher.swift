// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

struct WebSocketTaskPublisher: Publisher {
    typealias Output = URLSessionWebSocketTask.Message

    typealias Failure = URLError

    let task: URLSessionWebSocketTask

    /// Creates a WebSocket task publisher from the provided URL and URL session.
    ///
    /// The provided URL must have a `ws` or `wss` scheme.
    /// - Parameters:
    ///   - url: The WebSocket URL with which to connect.
    ///   - session: The URLSession to create the WebSocket task.
    ///
    init(with request: URLRequest, session: URLSession = URLSession.shared) {
        self.task = session.webSocketTask(with: request)
    }

    func receive<S>(subscriber: S)
        where S: Subscriber, URLError == S.Failure,
        URLSessionWebSocketTask.Message == S.Input
    {

        let subscrption = Subscription(task: task, target: subscriber)
        subscriber.receive(subscription: subscrption)
    }
}

extension WebSocketTaskPublisher {
    class Subscription<Target: Subscriber>: Combine.Subscription
        where Target.Input == Output,
        Target.Failure == URLError
    {

        let task: URLSessionWebSocketTask
        var target: Target?

        init(task: URLSessionWebSocketTask, target: Target) {
            self.task = task
            self.target = target
        }

        func request(_ demand: Subscribers.Demand) {
            guard let target else { return }
            // Resume the task
            task.resume()
            listen(for: target, with: demand)
        }

        func listen(for target: Target, with demand: Subscribers.Demand) {
            var demand = demand

            task.receive { [weak self] result in
                switch result {
                case .success(let message):
                    demand -= 1
                    demand += target.receive(message)

                case .failure:
                    target.receive(completion: .failure(URLError(.badServerResponse, userInfo: [:])))
                }

                if demand > 0 {
                    self?.listen(for: target, with: demand)
                }
            }
        }

        func cancel() {
            task.cancel()
            target = nil
        }
    }
}
