// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

final class WalletRepo: WalletRepoAPI {
    private var state: CurrentValueSubject<WalletRepoState, Never>
    private let publisher: AnyPublisher<WalletRepoState, Never>

    init(initialState: WalletRepoState) {
        self.state = CurrentValueSubject<WalletRepoState, Never>(initialState)
        self.publisher = state
            .eraseToAnyPublisher()
    }

    /// Gets the current value of the `WalletRepoState`
    /// - Returns: `Publisher.First<WalletRepoState, Never>`
    func get() -> Publishers.First<AnyPublisher<WalletRepoState, Never>> {
        publisher.first()
    }

    /// Streams the value of the underlying state of `WalletRepoState`
    /// - Returns: `AnyPublisher<WalletRepoState, Never>`
    func stream() -> AnyPublisher<WalletRepoState, Never> {
        publisher.eraseToAnyPublisher()
    }

    /// Returns the resulting value of a given key path.
    subscript<LocalState>(
        dynamicMember keyPath: KeyPath<WalletRepoState, LocalState>
    ) -> LocalState {
        state.value[keyPath: keyPath]
    }

    /// Returns the resulting publisher of a given key path.
    subscript<LocalState>(
        dynamicMember keyPath: KeyPath<WalletRepoState, LocalState>
    ) -> AnyPublisher<LocalState, Never>
        where LocalState: Equatable
    {
        state.map(keyPath)
            .eraseToAnyPublisher()
    }

    /// Sets an new `WalletStorageState` value
    /// - Parameter value: A `WalletStorageState` to be set.
    @discardableResult
    func set<Value>(
        keyPath: WritableKeyPath<WalletRepoState, Value>,
        value: Value
    ) -> Self {
        state.value[keyPath: keyPath] = value
        return self
    }

    /// Sets an new `WalletStorageState` value.
    ///
    /// - Parameter value: A `WalletStorageState` to be set.
    @discardableResult
    func set(
        value: WalletRepoState
    ) -> Self {
        state.send(value)
        return self
    }
}
