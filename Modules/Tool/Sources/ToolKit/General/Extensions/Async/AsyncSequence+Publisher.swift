// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension AsyncSequence {

    public func publisher() -> AsyncThrowingSequencePublisher<Self> {
        .init(self)
    }
}

extension Publisher where Failure == Never {

    @available(iOS, deprecated: 15.0, message: "Use publisher.values directly")
    @available(macOS, deprecated: 12.0, message: "Use publisher.values directly")
    public var values: AsyncPublisher<Self> {
        AsyncPublisher(self)
    }
}

extension Publisher {

    @available(iOS, deprecated: 15.0, message: "Use publisher.values directly")
    @available(macOS, deprecated: 12.0, message: "Use publisher.values directly")
    public var values: AsyncThrowingPublisher<Self> {
        AsyncThrowingPublisher(self)
    }

    public func await() async throws -> Output? {
        try await values.first
    }
}

extension AsyncPublisher {

    public var first: P.Output? {
        get async {
            for await o in self {
                return o
            }
            return nil
        }
    }
}

extension AsyncThrowingPublisher {

    public var first: P.Output? {
        get async throws {
            for try await o in self {
                return o
            }
            return nil
        }
    }
}

extension AsyncSequence {

    public var first: Element? {
        get async throws {
            for try await o in self {
                return o
            }
            return nil
        }
    }
}

// Once it is possible to express conformance to a non-throwing async sequence we should create a new type
// `AsyncSequencePublisher<S: nothrow AsyncSequence>`. At the moment the safest thing to do is capture the error and
// allow the consumer to ignore it if they wish
public struct AsyncThrowingSequencePublisher<S: AsyncSequence>: Combine.Publisher {

    public typealias Output = S.Element
    public typealias Failure = Error

    private var sequence: S

    public init(_ sequence: S) {
        self.sequence = sequence
    }

    public func receive<S>(
        subscriber: S
    ) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(
            subscription: Subscription(subscriber: subscriber, sequence: sequence)
        )
    }

    actor Subscription<
        Subscriber: Combine.Subscriber
    >: Combine.Subscription where Subscriber.Input == Output, Subscriber.Failure == Failure {

        private var sequence: S
        private var subscriber: Subscriber
        private var isCancelled = false

        private var demand: Subscribers.Demand = .none
        private var task: Task<Void, Error>?

        init(subscriber: Subscriber, sequence: S) {
            self.sequence = sequence
            self.subscriber = subscriber
        }

        nonisolated func request(_ demand: Subscribers.Demand) {
            Task { await _request(demand) }
        }

        private func _request(_ __demand: Subscribers.Demand) {
            demand = __demand
            guard demand > 0 else { return }
            task?.cancel()
            task = Task {
                var iterator = sequence.makeAsyncIterator()
                while !isCancelled, demand > 0 {
                    let element: S.Element?
                    do {
                        element = try await iterator.next()
                    } catch is CancellationError {
                        subscriber.receive(completion: .finished)
                        return
                    } catch {
                        subscriber.receive(completion: .failure(error))
                        throw CancellationError()
                    }
                    guard let element = element else {
                        subscriber.receive(completion: .finished)
                        throw CancellationError()
                    }
                    try Task.checkCancellation()
                    demand -= 1
                    demand += subscriber.receive(element)
                    await Task.yield()
                }
            }
        }

        nonisolated func cancel() {
            Task { await _cancel() }
        }

        private func _cancel() {
            task?.cancel()
            isCancelled = true
        }
    }
}

@available(macOS 12.0, iOS 15.0, *)
extension Combine.AsyncPublisher {

    public var first: P.Output? {
        get async {
            for await o in self {
                return o
            }
            return nil
        }
    }
}

@available(macOS 12.0, iOS 15.0, *)
extension Combine.AsyncThrowingPublisher {

    public var first: P.Output? {
        get async throws {
            for try await o in self {
                return o
            }
            return nil
        }
    }
}

@available(iOS, deprecated: 15.0, message: "Use Combine.AsyncPublisher directly")
@available(macOS, deprecated: 12.0, message: "Use Combine.AsyncPublisher directly")
public struct AsyncPublisher<P: Publisher>: AsyncSequence where P.Failure == Never {

    public typealias Element = P.Output

    private let publisher: P

    init(_ publisher: P) {
        self.publisher = publisher
    }

    public func makeAsyncIterator() -> Iterator {
        let stream = AsyncStream(Element.self, bufferingPolicy: .bufferingOldest(1)) { continuation in
            publisher.receive(subscriber: Subscriber(continuation: continuation))
        }
        var iterator = stream.makeAsyncIterator()
        return Iterator { await iterator.next() }
    }

    public struct Iterator: AsyncIteratorProtocol {
        let _next: () async -> P.Output?

        public mutating func next() async -> P.Output? {
            await _next()
        }
    }
}

extension AsyncPublisher {

    actor Subscriber: Combine.Subscriber {

        typealias Continuation = AsyncStream<Input>.Continuation

        private var subscription: Subscription?
        private let continuation: Continuation

        init(continuation: Continuation) {
            self.continuation = continuation
        }

        nonisolated func receive(subscription: Subscription) {
            Task { await _receive(subscription: subscription) }
        }

        func _receive(subscription: Subscription) {
            self.subscription = subscription
            continuation.onTermination = { @Sendable _ in
                subscription.cancel()
            }
            subscription.request(.max(1))
        }

        nonisolated func receive(_ input: Element) -> Subscribers.Demand {
            Task { await _receive(input) }
            return .none
        }

        func _receive(_ input: Element) {
            continuation.yield(input)
            Task { [subscription] in
                subscription?.request(.max(1))
            }
        }

        nonisolated func receive(completion: Subscribers.Completion<Never>) {
            Task { await _receive(completion: completion) }
        }

        func _receive(completion: Subscribers.Completion<Never>) {
            subscription = nil
            continuation.finish()
        }
    }
}

@available(iOS, deprecated: 15.0, message: "Use Combine.AsyncThrowingPublisher directly")
@available(macOS, deprecated: 12.0, message: "Use Combine.AsyncThrowingPublisher directly")
public struct AsyncThrowingPublisher<P: Publisher>: AsyncSequence {

    public typealias Element = P.Output

    private let publisher: P

    init(_ publisher: P) {
        self.publisher = publisher
    }

    public func makeAsyncIterator() -> Iterator {
        let stream = AsyncThrowingStream(Element.self, bufferingPolicy: .bufferingOldest(1)) { continuation in
            publisher.eraseError().receive(subscriber: Subscriber(continuation: continuation))
        }
        var iterator = stream.makeAsyncIterator()
        return Iterator { try await iterator.next() }
    }

    public struct Iterator: AsyncIteratorProtocol {
        let _next: () async throws -> P.Output?

        public mutating func next() async throws -> P.Output? {
            try await _next()
        }
    }
}

extension AsyncThrowingPublisher {

    actor Subscriber: Combine.Subscriber {

        typealias Continuation = AsyncThrowingStream<Input, Error>.Continuation

        private var subscription: Subscription?
        private let continuation: Continuation

        init(continuation: Continuation) {
            self.continuation = continuation
        }

        nonisolated func receive(subscription: Subscription) {
            Task { await _receive(subscription: subscription) }
        }

        func _receive(subscription: Subscription) {
            self.subscription = subscription
            continuation.onTermination = { @Sendable _ in
                subscription.cancel()
            }
            subscription.request(.max(1))
        }

        nonisolated func receive(_ input: Element) -> Subscribers.Demand {
            Task { await _receive(input) }
            return .none
        }

        func _receive(_ input: Element) {
            continuation.yield(input)
            Task { [subscription] in
                subscription?.request(.max(1))
            }
        }

        nonisolated func receive(completion: Subscribers.Completion<Error>) {
            Task { await _receive(completion: completion) }
        }

        func _receive(completion: Subscribers.Completion<Error>) {
            subscription = nil
            switch completion {
            case .finished:
                continuation.finish(throwing: nil)
            case .failure(let error):
                continuation.finish(throwing: error)
            }
        }
    }
}
