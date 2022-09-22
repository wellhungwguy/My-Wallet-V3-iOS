// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Extensions
import Foundation

/// An in-memory cache implementation.
public final class InMemoryCache<Key: Hashable, Value: Equatable>: CacheAPI {

    // MARK: - Private Types

    /// An item stored inside the cache.
    private struct CacheItem: Equatable {

        /// The cache value.
        let value: Value

        /// The time when the cache value was last refreshed.
        var lastRefresh = Date()
    }

    // MARK: - Private Properties

    private let cacheItems = Atomic<[Key: CacheItem]>([:])

    private let refreshControl: CacheRefreshControl

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup

    /// Creates an in-memory cache.
    ///
    /// - Parameters:
    ///   - configuration:  A cache configuration.
    ///   - refreshControl: A cache refresh control.
    public init(
        configuration: CacheConfiguration,
        refreshControl: CacheRefreshControl,
        notificationCenter: NotificationCenter = .default
    ) {
        self.refreshControl = refreshControl

        for flushNotificationName in configuration.flushNotificationNames {
            notificationCenter
                .publisher(for: flushNotificationName)
                .flatMap { [removeAll] _ in removeAll() }
                .subscribe()
                .store(in: &cancellables)
        }
    }

    // MARK: - Public Properties

    public func get(key: Key) -> AnyPublisher<CacheValue<Value>, Never> {
        Deferred { [cacheItems, toCacheValue] () -> AnyPublisher<CacheValue<Value>, Never> in
            let cacheItem = cacheItems.value[key]
            let cacheValue = toCacheValue(cacheItem)

            return .just(cacheValue)
        }
        .eraseToAnyPublisher()
    }

    public func stream(key: Key) -> AnyPublisher<CacheValue<Value>, Never> {
        cacheItems.publisher
            .map { $0[key] }
            .removeDuplicates()
            .map(toCacheValue)
            .share()
            .eraseToAnyPublisher()
    }

    public func set(_ value: Value, for key: Key) -> AnyPublisher<Value?, Never> {
        Deferred { [cacheItems] () -> AnyPublisher<Value?, Never> in
            let cacheItem = cacheItems.mutateAndReturn { $0.updateValue(CacheItem(value: value), forKey: key) }
            let cacheValue = cacheItem?.value

            return .just(cacheValue)
        }
        .eraseToAnyPublisher()
    }

    public func remove(key: Key) -> AnyPublisher<Value?, Never> {
        Deferred { [cacheItems] () -> AnyPublisher<Value?, Never> in
            let cacheItem = cacheItems.mutateAndReturn { $0.removeValue(forKey: key) }
            let cacheValue = cacheItem?.value

            return .just(cacheValue)
        }
        .eraseToAnyPublisher()
    }

    public func removeAll() -> AnyPublisher<Void, Never> {
        Deferred { [cacheItems] () -> AnyPublisher<Void, Never> in
            cacheItems.mutate { $0 = [:] }

            return .just(())
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    /// Maps the given cache item to a cache value.
    ///
    /// - Parameter cacheItem: A cache item.
    ///
    /// - Returns: A cache value.
    private func toCacheValue(cacheItem: CacheItem?) -> CacheValue<Value> {
        guard let cacheItem = cacheItem else {
            return .absent
        }

        if refreshControl.shouldRefresh(lastRefresh: cacheItem.lastRefresh) {
            return .stale(cacheItem.value)
        }

        return .present(cacheItem.value)
    }
}
