// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Session {

    public typealias Events = PassthroughSubject<Session.Event, Never>

    public struct Event: Identifiable, Hashable {

        public let id: UInt
        public let date: Date
        public let event: Tag.Event
        public let reference: Tag.Reference
        public let context: Tag.Context

        public let source: (file: String, line: Int)

        public var tag: Tag { reference.tag }

        init(
            date: Date = Date(),
            event: Tag.Event,
            reference: Tag.Reference,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) {
            id = Self.id
            self.date = date
            self.event = event
            self.reference = reference
            self.context = context
            source = (file, line)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension Session.Event: CustomStringConvertible {
    public var description: String { String(describing: event) }
}

extension Session.Event {
    private static var count: UInt = 0
    private static let lock = NSLock()
    private static var id: UInt {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }
}

extension Publisher where Output == Session.Event {

    public func filter(_ type: L) -> Publishers.Filter<Self> {
        filter(type[])
    }

    public func filter(_ type: Tag) -> Publishers.Filter<Self> {
        filter(type.reference)
    }

    public func filter(_ type: Tag.Reference) -> Publishers.Filter<Self> {
        filter([type])
    }

    public func filter<S: Sequence>(_ types: S) -> Publishers.Filter<Self> where S.Element == Tag {
        filter { $0.reference.tag.is(types) }
    }

    public func filter<S: Sequence>(_ types: S) -> Publishers.Filter<Self> where S.Element == Tag.Reference {
        filter { event in
            types.contains(where: { type in event.reference == type || event.tag.is(type.tag) })
        }
    }
}

extension AppProtocol {

    @inlinable public func on(
        _ first: Tag.Event,
        _ rest: Tag.Event...,
        file: String = #fileID,
        line: Int = #line,
        action: @escaping (Session.Event) throws -> Void
    ) -> BlockchainEventSubscription {
        on([first] + rest, file: file, line: line, action: action)
    }

    @inlinable public func on(
        _ first: Tag.Event,
        _ rest: Tag.Event...,
        file: String = #fileID,
        line: Int = #line,
        priority: TaskPriority? = nil,
        action: @escaping (Session.Event) async throws -> Void
    ) -> BlockchainEventSubscription {
        on([first] + rest, file: file, line: line, priority: priority, action: action)
    }

    @inlinable public func on<Events>(
        _ events: Events,
        file: String = #fileID,
        line: Int = #line,
        action: @escaping (Session.Event) throws -> Void
    ) -> BlockchainEventSubscription where Events: Sequence, Events.Element: Tag.Event {
        on(events.map { $0 as Tag.Event }, file: file, line: line, action: action)
    }

    @inlinable public func on<Events>(
        _ events: Events,
        file: String = #fileID,
        line: Int = #line,
        priority: TaskPriority? = nil,
        action: @escaping (Session.Event) async throws -> Void
    ) -> BlockchainEventSubscription where Events: Sequence, Events.Element: Tag.Event {
        on(events.map { $0 as Tag.Event }, file: file, line: line, priority: priority, action: action)
    }

    @inlinable public func on<Events>(
        _ events: Events,
        file: String = #fileID,
        line: Int = #line,
        action: @escaping (Session.Event) throws -> Void
    ) -> BlockchainEventSubscription where Events: Sequence, Events.Element == Tag.Event {
        BlockchainEventSubscription(
            app: self,
            events: Array(events),
            file: file,
            line: line,
            action: action
        )
    }

    @inlinable public func on<Events>(
        _ events: Events,
        file: String = #fileID,
        line: Int = #line,
        priority: TaskPriority? = nil,
        action: @escaping (Session.Event) async throws -> Void
    ) -> BlockchainEventSubscription where Events: Sequence, Events.Element == Tag.Event {
        BlockchainEventSubscription(
            app: self,
            events: Array(events),
            file: file,
            line: line,
            priority: priority,
            action: action
        )
    }
}

public final class BlockchainEventSubscription: Hashable {

    enum Action {
        case sync((Session.Event) throws -> Void)
        case async((Session.Event) async throws -> Void)
    }

    let id: UInt
    let app: AppProtocol
    let events: [Tag.Event]
    let action: Action
    let priority: TaskPriority?

    let file: String, line: Int

    deinit { stop() }

    @usableFromInline init(
        app: AppProtocol,
        events: [Tag.Event],
        file: String,
        line: Int,
        action: @escaping (Session.Event) throws -> Void
    ) {
        id = Self.id
        self.app = app
        self.events = events
        self.file = file
        self.line = line
        priority = nil
        self.action = .sync(action)
    }

    @usableFromInline init(
        app: AppProtocol,
        events: [Tag.Event],
        file: String,
        line: Int,
        priority: TaskPriority? = nil,
        action: @escaping (Session.Event) async throws -> Void
    ) {
        id = Self.id
        self.app = app
        self.events = events
        self.file = file
        self.line = line
        self.priority = priority
        self.action = .async(action)
    }

    private var subscription: AnyCancellable?

    @discardableResult
    public func start() -> Self {
        guard subscription == nil else { return self }
        subscription = app.on(events).sink(
            receiveValue: { [weak self] event in
                guard let self = self else { return }
                switch self.action {
                case .sync(let action):
                    do {
                        try action(event)
                    } catch {
                        self.app.post(error: error, file: self.file, line: self.line)
                    }
                case .async(let action):
                    Task(priority: self.priority) {
                        do {
                            try await action(event)
                        } catch {
                            self.app.post(error: error, file: self.file, line: self.line)
                        }
                    }
                }
            }
        )
        return self
    }

    @discardableResult
    public func stop() -> Self {
        subscription?.cancel()
        subscription = nil
        return self
    }
}

extension BlockchainEventSubscription {

    public func subscribe() -> AnyCancellable {
        start()
        return AnyCancellable { [self] in stop() }
    }

    private static var count: UInt = 0
    private static let lock = NSLock()
    private static var id: UInt {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }

    public static func == (lhs: BlockchainEventSubscription, rhs: BlockchainEventSubscription) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
