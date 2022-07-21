// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Publisher where Failure == Never {

    public func task<T>(
        priority: TaskPriority? = nil,
        maxPublishers demand: Subscribers.Demand = .unlimited,
        _ yield: @escaping (Output) async -> T
    ) -> AnyPublisher<T, Never> {
        flatMap(maxPublishers: demand) { value -> Task<T, Never>.Publisher in
            Task<T, Never>.Publisher(priority: priority) {
                await yield(value)
            }
        }
        .eraseToAnyPublisher()
    }

    public func task<T>(
        priority: TaskPriority? = nil,
        maxPublishers demand: Subscribers.Demand = .unlimited,
        _ yield: @escaping (Output) async throws -> T
    ) -> AnyPublisher<T, Error> {
        setFailureType(to: Error.self)
            .flatMap(maxPublishers: demand) { value -> Task<T, Error>.Publisher in
                Task<T, Error>.Publisher(priority: priority) {
                    try await yield(value)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func task<T>(
        priority: TaskPriority? = nil,
        maxPublishers demand: Subscribers.Demand = .unlimited,
        _ yield: @escaping (Output) async throws -> T
    ) -> AnyPublisher<T, Error> {
        eraseError()
            .flatMap(maxPublishers: demand) { value -> Task<T, Error>.Publisher in
                Task<T, Error>.Publisher(priority: priority) {
                    try await yield(value)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Task {

    public struct Publisher: Combine.Publisher {

        private enum YieldingFailure {
            case error(@Sendable () async throws -> Output)
            case never(@Sendable () async -> Output)
        }

        public typealias Output = Success

        private let priority: TaskPriority?
        private let yield: YieldingFailure

        public init(
            priority: TaskPriority? = nil,
            _ yield: @escaping @Sendable () async -> Output
        ) where Failure == Never {
            self.priority = priority
            self.yield = .never(yield)
        }

        public init(
            priority: TaskPriority? = nil,
            _ yield: @escaping @Sendable () async throws -> Output
        ) {
            self.priority = priority
            self.yield = .error(yield)
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            switch yield {
            case .never(let yield):
                subscriber.receive(
                    subscription: Subscription(priority: priority, yield: yield, downstream: subscriber)
                )
            case .error(let yield):
                subscriber.receive(
                    subscription: ThrowingSubscription(priority: priority, yield: yield, downstream: subscriber)
                )
            }
        }

        actor Subscription: Combine.Subscription {

            private let yield: @Sendable () async -> Output
            private let priority: TaskPriority?
            private var task: Task<Void, Never>?
            private var downstream: AnySubscriber<Output, Failure>?

            init<Downstream>(
                priority: TaskPriority?,
                yield: @escaping @Sendable () async -> Output,
                downstream: Downstream
            ) where Downstream: Subscriber, Output == Downstream.Input, Downstream.Failure == Failure {
                self.priority = priority
                self.yield = yield
                self.downstream = AnySubscriber(downstream)
            }

            func receive(_ input: Output) {
                _ = downstream?.receive(input)
                downstream?.receive(completion: .finished)
                task = nil
                downstream = nil
            }

            nonisolated func request(_ demand: Subscribers.Demand) {
                Task<Void, Never> { await _request(demand) }
            }

            private func _request(_ demand: Subscribers.Demand) {
                guard demand > 0 else { return }
                guard task == nil else { return }
                task = .detached { [yield, weak self] in
                    let value = await yield()
                    await self?.receive(value)
                }
            }

            nonisolated func cancel() {
                Task<Void, Never> { await _cancel() }
            }

            private func _cancel() {
                task?.cancel()
                task = nil
                downstream = nil
            }
        }

        actor ThrowingSubscription: Combine.Subscription {

            private let yield: @Sendable () async throws -> Output
            private let priority: TaskPriority?
            private var task: Task<Void, Never>?
            private var downstream: AnySubscriber<Output, Failure>?

            init<Downstream>(
                priority: TaskPriority?,
                yield: @escaping @Sendable () async throws -> Output,
                downstream: Downstream
            ) where Downstream: Subscriber, Output == Downstream.Input, Downstream.Failure == Failure {
                self.priority = priority
                self.yield = yield
                self.downstream = AnySubscriber(downstream)
            }

            nonisolated func request(_ demand: Subscribers.Demand) {
                Task<Void, Never> { await _request(demand) }
            }

            func _request(_ demand: Subscribers.Demand) {
                guard demand > 0 else { return }
                guard task == nil else { return }
                task = .detached(priority: priority) { [yield, weak self] in
                    guard let self = self else { return }
                    do {
                        let value = try await yield()
                        await self.receive(value)
                    } catch let error as Failure {
                        await self.receive(error: error)
                    } catch {
                        await self._cancel()
                        assert(error is Failure, "Expected \(Failure.self), got \(type(of: error))")
                    }
                }
            }

            nonisolated func cancel() {
                Task<Void, Never> { await _cancel() }
            }

            func _cancel() {
                task?.cancel()
                task = nil
                downstream = nil
            }

            private func receive(_ input: Output) {
                _ = downstream?.receive(input)
                downstream?.receive(completion: .finished)
                task = nil
                downstream = nil
            }

            private func receive(error: Failure) {
                _ = downstream?.receive(completion: .failure(error))
                task = nil
                downstream = nil
            }
        }
    }
}
