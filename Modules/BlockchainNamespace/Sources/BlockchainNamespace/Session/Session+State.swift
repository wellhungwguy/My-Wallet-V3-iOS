// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import SwiftExtensions

extension Session {

    public final class State {

        unowned var app: AppProtocol!
        var data: Data

        public init(
            _ data: Tag.Context = [:],
            preferences: Preferences = UserDefaults.standard
        ) {
            self.data = Data(preferences: preferences)
            self.data.store = data.dictionary
        }
    }
}

extension Session.State {

    public class Data {

        public internal(set) var store: [Tag.Reference: Any] = [:]
        internal var subjects: [Tag.Reference: Subject] = [:]
        private var dirty: (data: [Tag.Reference: Any], level: UInt) = ([:], 0)

        private let lock = NSRecursiveLock()

        var preferences: Preferences

        private let shared = Tag.Context.genericIndex
        private var user: String? {
            sync { store[blockchain.user.id.key()] } as? String
        }

        init(preferences: Preferences) {
            self.preferences = preferences
        }
    }

    private func key(_ event: Tag.Event) -> Tag.Reference {
        event.key().in(app)
    }
}

extension Session.State {

    public struct Function: Hashable {

        public let id: UUID = UUID()
        public let call: () throws -> Any?

        public init<T>(_ call: @escaping () -> T) {
            self.call = call as () throws -> Any?
        }

        public init<T>(_ call: @escaping () throws -> T) {
            self.call = call as () throws -> Any?
        }

        @discardableResult
        public func callAsFunction() throws -> Any? {
            try call()
        }

        public static func == (x: Function, y: Function) -> Bool {
            x.id == y.id
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

extension Session.State.Data {

    private struct Tombstone: Hashable {}

    public struct Computed {
        public let key: Tag.Reference
        public let yield: () throws -> Any
    }
}

extension Session.State {

    public func transaction(_ yield: (Session.State) throws -> some Any) {
        data.beginTransaction()
        do {
            _ = try yield(self)
            data.endTransaction()
        } catch {
            data.rollbackTransaction()
        }
    }

    public func doesNotContain(_ event: Tag.Event) -> Bool {
        !data.store.keys.contains(key(event))
    }

    public func contains(_ event: Tag.Event) -> Bool {
        data.store.keys.contains(key(event))
    }

    public func clear(_ event: Tag.Event) {
        let key = key(event)
        if key.tag.is(blockchain.user.id) {
            transaction { state in
                let user = key
                for key in data.store.keys where key.tag.isNot(blockchain.session.state.shared.value) {
                    guard key.tag.isNot(blockchain.session.state.preference.value) else { continue }
                    guard key != user else { continue }
                    state.clear(key)
                }
            }
        }
        data.clear(key)
    }

    public func set(_ event: Tag.Event, to value: Any?) {
        data.set(key(event), to: value as Any)
    }

    public func set(_ event: Tag.Event, to value: @escaping () throws -> Any) {
        let key = key(event)
        set(key, to: Data.Computed(key: key, yield: value))
    }

    public func set(_ reference: Tag.Reference, to value: Any?) {
        data.set(reference, to: value as Any)
    }

    public func get(_ event: Tag.Event) throws -> Any {
        try data.get(key(event))
    }

    public func get<T: Decodable>(
        _ event: Tag.Event,
        as type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try decoder.decode(T.self, from: get(event) as Any)
    }

    @_disfavoredOverload
    public func get<T>(
        _ event: Tag.Event,
        as type: T.Type = T.self
    ) throws -> T {
        try (get(event) as? T).or(
            throw: FetchResult.Error.decoding(.init(message: "Error casting \(event) to \(T.self)", at: []))
        )
    }

    public func result(for event: Tag.Event) -> FetchResult {
        let key = key(event)
        do {
            return try .value(get(key), key.metadata(.state))
        } catch let error as FetchResult.Error {
            return .error(error, key.metadata(.state))
        } catch {
            return .error(.other(error), key.metadata(.state))
        }
    }

    public func publisher(for event: Tag.Event) -> AnyPublisher<FetchResult, Never> {
        let key = key(event)
        return Just(result(for: key))
            .merge(with: data.subject(for: key))
            .eraseToAnyPublisher()
    }
}

extension FetchResult {
    @inlinable public var isYes: Bool { (value as? Bool) == true }
    @inlinable public var isNo: Bool { (value as? Bool) == false }
}

extension Session.State {

    @inlinable public func yes(
        if ifs: L & I_blockchain_db_type_boolean...,
        unless buts: L & I_blockchain_db_type_boolean...
    ) -> Bool {
        yes(if: ifs, unless: buts)
    }

    @inlinable public func yes(
        if ifs: [L & I_blockchain_db_type_boolean],
        unless buts: [L & I_blockchain_db_type_boolean]
    ) -> Bool {
        ifs.allSatisfy { result(for: $0).isYes } && buts.none { result(for: $0).isYes }
    }

    @inlinable public func no(
        if ifs: L & I_blockchain_db_type_boolean...,
        unless buts: L & I_blockchain_db_type_boolean...
    ) -> Bool {
        no(if: ifs, unless: buts)
    }

    @inlinable public func no(
        if ifs: [L & I_blockchain_db_type_boolean],
        unless buts: [L & I_blockchain_db_type_boolean]
    ) -> Bool {
        yes(if: ifs, unless: buts) ? false : true
    }
}

extension Session.State.Data {

    public var isInTransaction: Bool { sync { dirty.level > 0 } }
    public var isNotInTransaction: Bool { !isInTransaction }

    public func contains(_ key: Tag.Reference) -> Bool {
        sync { store.keys.contains(key) }
    }

    func get(_ key: Tag.Reference) throws -> Any {
        if let value = sync(execute: { store[key] }) {
            return try (value as? Computed)?.yield() ?? value
        }

        let tag = key.tag
        switch tag {
        case blockchain.session.state.preference.value:
            guard let value = tag.is(blockchain.session.state.shared.value)
                ? preference(key, in: shared)
                : user.flatMap({ user in preference(key, in: user) })
            else {
                throw FetchResult.Error.keyDoesNotExist(key)
            }
            set(key, to: value)
            return value
        default:
            throw FetchResult.Error.keyDoesNotExist(key)
        }
    }

    func set(_ key: Tag.Reference, to value: Any) {
        sync { dirty.data[key] = value }
        if isNotInTransaction {
            update([key: value])
        }
        if key.tag == blockchain.user.id[], let id = value as? String {
            beginTransaction()
            let user = key
            let keys = sync { subjects.keys }
            for key in keys {
                guard key != user else { continue }
                guard key.tag.is(blockchain.session.state.preference.value) else { continue }
                guard key.tag.isNot(blockchain.session.state.shared.value) else { continue }
                guard let value = preference(key, in: id) else { continue }
                set(key, to: value)
            }
            endTransaction()
        }
    }

    private func preference(_ key: Tag.Reference, in scope: String) -> Any? {
        preferences.object(forKey: blockchain.session.state(\.id))[scope, key.string]
    }

    func clear(_ key: Tag.Reference) {
        if isInTransaction {
            sync { dirty.data[key] = Tombstone.self }
        } else {
            update([key: Tombstone.self])
        }
    }

    func beginTransaction() {
        sync {
            dirty.level += 1
        }
    }

    func endTransaction() {
        let data: [Tag.Reference: Any]? = sync {
            let data = dirty.data
            switch dirty.level {
            case 1:
                dirty.data.removeAll(keepingCapacity: true)
                dirty.level = 0
                return data
            case 1...UInt.max:
                dirty.level -= 1
                return nil
            default:
                assertionFailure(
                    "Misaligned begin -> end transaction calls. You must be in a transaction to end a transaction."
                )
                return nil
            }
        }
        if let data {
            update(data)
        }
    }

    func rollbackTransaction() {
        sync {
            precondition(isInTransaction)
            dirty.level = 0
            dirty.data.removeAll(keepingCapacity: true)
        }
    }

    func subject(for key: Tag.Reference) -> Session.State.Subject {
        sync {
            let subject = subjects[key, default: .init()]
            subjects[key] = subject
            return subject
        }
    }

    private func update(_ data: [Tag.Reference: Any]) {
        for (key, value) in data {
            switch value {
            case is Tombstone.Type:
                sync { store.removeValue(forKey: key) }
            default:
                sync { store[key] = value }
            }
        }
        preferences.transaction(blockchain.session.state(\.id)) { object in
            update(
                object: &object,
                from: data,
                scope: shared,
                filter: { $0.is(blockchain.session.state.shared.value) }
            )
            if let user {
                update(
                    object: &object,
                    from: data,
                    scope: user,
                    filter: { $0.isNot(blockchain.session.state.shared.value) }
                )
            } else {
                #if DEBUG
                let preferences = data.keys.filter { key in
                    key.tag.is(blockchain.session.state.preference.value)
                        && key.tag.isNot(blockchain.session.state.shared.value)
                }
                if preferences.isNotEmpty {
                    print(
                        """
                        ⚠️ Attempted to write user preference without being signed in.

                        If you meant this to be written against the user, please ensure you are signed in
                        before attempting to write - you can observe `blockchain.session.event.did.sign.in`.

                        Most commonly, you will see this if you have mistakenly not marked a shared state value
                        as `blockchain.session.state.shared.value`.

                        \(preferences.map(\.string).joined(by: ", "))
                        """
                    )
                }
                #endif
            }
        }
        for (key, value) in data {
            let subject = sync { subjects[key] }
            switch value {
            case is Tombstone.Type:
                subject?.send(.error(.keyDoesNotExist(key), key.metadata(.state)))
            default:
                subject?.send(.value(value, key.metadata(.state)))
            }
        }
    }

    private func update(object: inout Any?, from data: [Tag.Reference: Any], scope: String, filter: (Tag) -> Bool) {
        var dictionary = object[scope] as? [String: Any] ?? [:]
        for (key, value) in data.filter({ key, _ in
            key.tag.is(blockchain.session.state.preference.value) && filter(key.tag)
        }) {
            if value is Tombstone.Type {
                dictionary.removeValue(forKey: key.id())
            } else {
                dictionary[key.id()] = value
            }
        }
        object[scope] = dictionary
    }

    @discardableResult
    func sync<T>(execute work: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try work()
    }
}

extension Session.State {
    public typealias Subject = PassthroughSubject<FetchResult, Never>
}
