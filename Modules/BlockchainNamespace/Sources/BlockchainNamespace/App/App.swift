// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Extensions
import FirebaseProtocol
import Foundation
import OptionalSubscripts

#if canImport(AppKit)
import AppKit
#endif

public protocol AppProtocol: AnyObject, CustomStringConvertible {

    var language: Language { get }

    var events: Session.Events { get }
    var state: Session.State { get }
    var remoteConfiguration: Session.RemoteConfiguration { get }
    var deepLinks: App.DeepLink { get }
    var local: Optional<Any>.Store { get }

    var clientObservers: Client.Observers { get }
    var sessionObservers: Session.Observers { get }

    #if canImport(SwiftUI)
    var environmentObject: App.EnvironmentObject { get }
    #endif
}

public class App: AppProtocol {

    public let language: Language

    public let events: Session.Events
    public let state: Session.State
    public let remoteConfiguration: Session.RemoteConfiguration

    #if canImport(SwiftUI)
    public lazy var environmentObject = App.EnvironmentObject(self)
    #endif

    public let local = Any?.Store()

    public lazy var deepLinks = DeepLink(self)

    public let clientObservers: Client.Observers
    public lazy var sessionObservers: Session.Observers = .init(app: self)

    public convenience init(
        language: Language = Language.root.language,
        remote: some RemoteConfiguration_p
    ) {
        self.init(
            language: language,
            remoteConfiguration: Session.RemoteConfiguration(remote: remote)
        )
    }

    @_disfavoredOverload
    public convenience init(
        language: Language = Language.root.language,
        state: Session.State = .init(),
        remoteConfiguration: Session.RemoteConfiguration
    ) {
        self.init(
            language: language,
            state: state,
            remoteConfiguration: remoteConfiguration
        )
    }

    init(
        language: Language = Language.root.language,
        events: Session.Events = .init(),
        state: Session.State = .init(),
        clientObservers: Client.Observers = .init(),
        remoteConfiguration: Session.RemoteConfiguration
    ) {
        defer { start() }
        self.language = language
        self.events = events
        self.state = state
        self.clientObservers = clientObservers
        self.remoteConfiguration = remoteConfiguration
    }

    deinit {
        for o in __observers {
            o.stop()
        }
    }

    private func start() {
        state.app = self
        deepLinks.start()
        sessionObservers.subscribe()
        remoteConfiguration.start(app: self)
        do {
            #if DEBUG
            _ = logger
            #endif
        }
        for o in __observers {
            o.start()
        }
    }

    // Observers

    private lazy var logger = events.sink { event in
        if
            let message = event.context[e.message] as? String,
            let file = event.context[e.file] as? String,
            let line = event.context[e.line] as? Int
        {
            print("🏷 ‼️", event.reference, message, "←", file, line)
        } else {
            print("🏷", event.reference, "←", event.source.file, event.source.line)
        }
    }

    private lazy var __observers = [
        actions,
        sets,
        urls
    ]

    private lazy var actions = on(blockchain.ui.type.action) { [weak self] event async throws in
        guard let self else { return }
        do {
            try await self.handle(action: event)
            let handled = try event.reference.tag.as(blockchain.ui.type.action).was.handled.key(to: event.reference.context)
            self.post(event: handled, context: event.context, file: event.source.file, line: event.source.line)
        } catch FetchResult.Error.keyDoesNotExist {
            return
        }
    }

    private lazy var sets = on(blockchain.ui.type.action.then.set.session.state) { [weak self] event throws in
        guard let self else { return }
        guard let action = event.action else { return }
        let data = try action.data.decode([String: AnyJSON].self).mapKeys { id in try Tag.Reference(id: id, in: self.language) }
        self.state.transaction { state in
            for (key, json) in data {
                state.set(key, to: json.any)
            }
        }
        for (key, json) in data {
            self.post(event: key, context: event.context + [key: json], file: event.source.file, line: event.source.line)
        }
    }

    private lazy var urls = on(blockchain.ui.type.action.then.launch.url) { [weak self] event throws in
        guard let self else { return }
        let url = try event.context.decode(blockchain.ui.type.action.then.launch.url, as: URL.self)
        guard self.deepLinks.canProcess(url: url) else {
            #if canImport(UIKit)
            UIApplication.shared.open(url)
            #elseif canImport(AppKit)
            NSWorkspace.shared.open(url)
            #endif
            return
        }
        self.post(
            event: blockchain.app.process.deep_link,
            context: event.context + [blockchain.app.process.deep_link.url: url],
            file: event.source.file,
            line: event.source.line
        )
    }
}

extension AppProtocol {

    public func signIn(userId: String) {
        post(event: blockchain.session.event.will.sign.in)
        state.transaction { state in
            state.set(blockchain.user.id, to: userId)
        }
        post(event: blockchain.session.event.did.sign.in)
        sessionObservers.reset()
    }

    public func signOut() {
        post(event: blockchain.session.event.will.sign.out)
        state.transaction { state in
            state.clear(blockchain.user.id)
        }
        post(event: blockchain.session.event.did.sign.out)
    }
}

extension AppProtocol {

    public func post(
        value: AnyHashable,
        of event: Tag.Event,
        file: String = #fileID,
        line: Int = #line
    ) {
        let reference = event.key().in(self)
        state.set(reference, to: value)
        post(
            event: event,
            reference: reference,
            context: [event: value],
            file: file,
            line: line
        )
    }

    public func post(
        event: Tag.Event,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        post(
            event: event,
            reference: event.key().in(self),
            context: context,
            file: file,
            line: line
        )
    }

    func post(
        event: Tag.Event,
        reference: Tag.Reference,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        events.send(
            Session.Event(
                origin: event,
                reference: reference,
                context: [
                    s.file: file,
                    s.line: line
                ] + context,
                file: file,
                line: line
            )
        )
    }

    public func post(
        _ tag: L_blockchain_ux_type_analytics_error,
        error: some Error,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        post(tag[], error: error, context: context, file: file, line: line)
    }

    public func post(
        error: some Error,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        if let error = error as? Tag.Error {
            post(error.event, error: error, context: context, file: error.file, line: error.line)
        } else {
            post(blockchain.ux.type.analytics.error, error: error, context: context, file: file, line: line)
        }
    }

    private func post(
        _ event: Tag.Event,
        error: some Error,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        post(
            event: event,
            context: context + [
                e.message: "\(error.localizedDescription)",
                e.file: file,
                e.line: line
            ]
        )
    }

    public func on(
        _ first: Tag.Event,
        _ rest: Tag.Event...
    ) -> AnyPublisher<Session.Event, Never> {
        on([first] + rest)
    }

    public func on(
        _ tags: some Sequence<Tag.Event>
    ) -> AnyPublisher<Session.Event, Never> {
        events.filter(tags.map { $0.key().in(self) })
            .eraseToAnyPublisher()
    }

    public func on(
        where filter: @escaping (Tag) -> Bool
    ) -> AnyPublisher<Session.Event, Never> {
        events.filter { filter($0.tag) }.eraseToAnyPublisher()
    }

    public func on(
        _ first: Tag.Event,
        _ rest: Tag.Event...,
        bufferingPolicy: AsyncStream<Session.Event>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<Session.Event> {
        on([first] + rest, bufferingPolicy: bufferingPolicy)
    }

    public func on(
        _ tags: some Sequence<Tag.Event>,
        bufferingPolicy: AsyncStream<Session.Event>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<Session.Event> {
        events.filter(tags.map { $0.key().in(self) }).stream(bufferingPolicy: bufferingPolicy)
    }
}

extension AppProtocol {

    public func post(
        action event: Tag.Event,
        value: some Any,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        do {
            let id = try event[].lineage.first(where: { tag in tag.is(blockchain.ui.type.action) })
                .or(throw: "\(event) is not an descendant of \(blockchain.ui.type.action)")
                .as(blockchain.ui.type.action)
            let ref = event.key().in(self)
            post(
                event: event,
                reference: ref,
                context: context + [
                    blockchain.ui.type.action: Action(
                        tag: id,
                        event: ref,
                        data: AnyJSON(value)
                    )
                ],
                file: file,
                line: line
            )
        } catch {
            post(error: error, context: context, file: file, line: line)
        }
    }
}

private let e = (
    message: blockchain.ux.type.analytics.error.message[],
    file: blockchain.ux.type.analytics.error.source.file[],
    line: blockchain.ux.type.analytics.error.source.line[]
)

private let s = (
    file: blockchain.ux.type.analytics.event.source.file[],
    line: blockchain.ux.type.analytics.event.source.line[]
)

extension AppProtocol {

    public func publisher<T: Equatable>(for event: Tag.Event, as _: T.Type = T.self) -> AnyPublisher<FetchResult.Value<T>, Never> {
        publisher(for: event).decode(T.self)
            .removeDuplicates(
                by: { lhs, rhs in (try? lhs.get() == rhs.get()) ?? false }
            )
            .eraseToAnyPublisher()
    }

    public func publisher<T>(for event: Tag.Event, as _: T.Type = T.self) -> AnyPublisher<FetchResult.Value<T>, Never> {
        publisher(for: event).decode(T.self)
    }

    public func publisher(for event: Tag.Event) -> AnyPublisher<FetchResult, Never> {

        func _publisher(_ ref: Tag.Reference) -> AnyPublisher<FetchResult, Never> {
            switch ref.tag {
            case blockchain.session.state.value, blockchain.db.collection.id:
                return state.publisher(for: ref)
            case blockchain.session.configuration.value:
                return remoteConfiguration.publisher(for: ref)
            default:
                return Task<AnyPublisher<FetchResult, Never>, Error>.Publisher { [local] () async throws -> AnyPublisher<FetchResult, Never> in
                    try await local.publisher(for: ref.route).map(FetchResult.create(ref.metadata(.app))).eraseToAnyPublisher()
                }
                .catch { error in .just(FetchResult.error(.other(error), ref.metadata(.app))) }
                .switchToLatest()
                .eraseToAnyPublisher()
            }
        }

        let ref = event.key().in(self)
        let ids = ref.context.mapKeys(\.tag)

        do {
            let dynamicKeys = try ref.tag.template.indices.set
                .subtracting(ids.keys.map(\.id))
                .map { try Tag(id: $0, in: language) }
            guard dynamicKeys.isNotEmpty else {
                return try _publisher(ref.validated())
            }
            let context = Tag.Context(ids)
            return try dynamicKeys.map { try $0.ref(to: context, in: self).validated() }
                .map(_publisher)
                .combineLatest()
                .flatMap { output -> AnyPublisher<FetchResult, Never> in
                    do {
                        let values = try output.map { try $0.decode(String.self).get() }
                        let indices = zip(dynamicKeys, values).reduce(into: [:]) { $0[$1.0] = $1.1 }
                        return try _publisher(ref.ref(to: context + Tag.Context(indices)).validated())
                            .eraseToAnyPublisher()
                    } catch {
                        return Just(.error(.other(error), Metadata(ref: ref, source: .app)))
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Just(.error(.other(error), Metadata(ref: ref, source: .app)))
                .eraseToAnyPublisher()
        }
    }

    public func get<T: Decodable>(_ event: Tag.Event, as _: T.Type = T.self) async throws -> T {
        try await publisher(for: event, as: T.self) // ← Invert this, foundation API is async/await with actor
            .stream()
            .next()
            .get()
    }

    public func stream(
        _ event: Tag.Event,
        bufferingPolicy: AsyncStream<FetchResult>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<FetchResult> {
        publisher(for: event).stream(bufferingPolicy: bufferingPolicy)
    }

    @_disfavoredOverload
    public func stream<T: Decodable>(
        _ event: Tag.Event,
        as _: T.Type = T.self,
        bufferingPolicy: AsyncStream<FetchResult.Value<T>>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<FetchResult.Value<T>> {
        publisher(for: event, as: T.self).stream(bufferingPolicy: bufferingPolicy)
    }
}

extension AppProtocol {

    public func set(_ event: Tag.Event, to value: Any?) async throws {
        let reference = event.key().in(self)
        switch reference.tag {
        case blockchain.session.state.value, blockchain.db.collection.id:
            state.set(reference, to: value)
        case blockchain.session.configuration.value:
            remoteConfiguration.override(reference, with: value as Any)
        default:
            if
                let collectionId = try? reference.tag.as(blockchain.db.collection).id[],
                !reference.indices.map(\.key).contains(collectionId)
            {
                guard let map = value as? [String: Any] else { throw "Not a collection" }
                var updates = Any?.Store.BatchUpdates()
                for (key, value) in map {
                    try updates.append((reference.key(to: [collectionId: key]).route, value))
                }
                await local.batch(updates)
            } else {
                try await local.set(reference.route, to: value)
            }
        }
        #if DEBUG
        if isInTest { await Task.megaYield(count: 20) }
        #endif
    }
}

extension Tag.Reference {

    var route: Optional<Any>.Store.Route {
        get throws {
            try validated()
                .tag.lineage
                .reversed()
                .flatMap { node -> [Optional<Any>.Store.Location] in
                    guard
                        let collectionId = node["id"],
                        let id = indices[collectionId]
                    else {
                        return [.key(node.name)]
                    }
                    return [.key(node.name), .key(id)]
                }
        }
    }
}

extension App {
    public var description: String { "App \(language.id)" }
}

extension App {

    public static var preview: AppProtocol = debug()

#if DEBUG
    public static var test: App.Test { App.Test() }
#endif

    /// Creates a mocked AppProtocol instance.
    public static func debug(
        preferences: Preferences = Mock.Preferences(),
        remoteConfiguration: some RemoteConfiguration_p = Mock.RemoteConfiguration(),
        session: URLSessionProtocol = URLSession.test,
        scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.test.eraseToAnyScheduler()
    ) -> AppProtocol {
        App(
            state: with(Session.State([:], preferences: preferences)) { state in
                state.data.keychain = (
                    user: Mock.Keychain(queryProvider: state.data.keychainAccount.user),
                    shared: Mock.Keychain(queryProvider: state.data.keychainAccount.shared)
                )
            },
            remoteConfiguration: Session.RemoteConfiguration(
                remote: remoteConfiguration,
                session: session,
                preferences: preferences,
                scheduler: scheduler
            )
        )
    }
}

var isInTest: Bool { NSClassFromString("XCTestCase") != nil }

extension App {

    public class Test: AppProtocol {

        private lazy var app: AppProtocol = App.debug(scheduler: scheduler.eraseToAnyScheduler())

        public var language: Language { app.language }
        public var events: Session.Events { app.events }
        public var state: Session.State { app.state }
        public var clientObservers: Client.Observers { app.clientObservers }
        public var sessionObservers: Session.Observers { app.sessionObservers }
        public var remoteConfiguration: Session.RemoteConfiguration { app.remoteConfiguration }
        public var scheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
        public var environmentObject: App.EnvironmentObject { app.environmentObject }
        public var deepLinks: DeepLink { app.deepLinks }
        public var local: Optional<Any>.Store { app.local }

        public var description: String { "Test App" }

        public func wait(
            _ event: Tag.Event
        ) async throws {
            _ = try await on(event, bufferingPolicy: .unbounded).next()
        }

        public func wait<S: Scheduler>(
            _ event: Tag.Event,
            timeout: S.SchedulerTimeType.Stride,
            scheduler: S = DispatchQueue.main
        ) async throws {
            _ = try await on(event).timeout(timeout, scheduler: scheduler).stream().next()
            await Task.megaYield(count: 20)
        }

        public func post(
            value: AnyHashable,
            of event: Tag.Event,
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(value: value, of: event, file: file, line: line)
            await Task.megaYield(count: 20)
        }

        public func post(
            event: Tag.Event,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(event: event, context: context, file: file, line: line)
            await Task.megaYield(count: 20)
        }

        public func post(
            _ tag: L_blockchain_ux_type_analytics_error,
            error: some Error,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(tag, error: error, context: context, file: file, line: line)
            await Task.megaYield(count: 20)
        }

        public func post(
            error: some Error,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(error: error, context: context, file: file, line: line)
            await Task.megaYield(count: 20)
        }

        func post(
            event: Tag.Event,
            reference: Tag.Reference,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) async {
            app.post(event: event, reference: reference, context: context, file: file, line: line)
            await Task.megaYield(count: 20)
        }
    }
}
