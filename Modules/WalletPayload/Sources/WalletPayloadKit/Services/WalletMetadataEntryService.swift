// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit

public enum WalletAssetFetchError: Error {
    case notInitialized
    case unavailable
    case fetchFailed(MetadataFetchError)
}

public enum WalletAssetSaveError: Error {
    case notInitialized
    case saveFailed(MetadataSaveError)
}

public protocol WalletMetadataEntryServiceAPI {
    /// Fetches a node entry from Metadata for the specified entry type
    /// - Parameter type: The type of Entry to be returned
    /// - Returns: An `AnyPublisher<Entry, WalletCoinFetchError>`
    func fetchEntry<Entry: MetadataNodeEntry>(
        type: Entry.Type
    ) -> AnyPublisher<Entry, WalletAssetFetchError>

    /// Saves a node entry to Metadata
    /// - Parameters:
    ///   - type: The type of Entry to be saved
    ///   - node: A `MetadataNodeEntry`
    /// - Returns: `AnyPublisher<EmptyValue, WalletAssetSaveError>`
    func save<Node: MetadataNodeEntry>(
        node: Node
    ) -> AnyPublisher<EmptyValue, WalletAssetSaveError>
}

final class WalletMetadataEntryService: WalletMetadataEntryServiceAPI {

    private let walletHolder: WalletHolderAPI
    private let metadataService: MetadataServiceAPI
    private let logger: NativeWalletLoggerAPI
    private let queue: DispatchQueue

    init(
        walletHolder: WalletHolderAPI,
        metadataService: MetadataServiceAPI,
        logger: NativeWalletLoggerAPI,
        queue: DispatchQueue
    ) {
        self.walletHolder = walletHolder
        self.metadataService = metadataService
        self.logger = logger
        self.queue = queue
    }

    func fetchEntry<Entry: MetadataNodeEntry>(
        type: Entry.Type
    ) -> AnyPublisher<Entry, WalletAssetFetchError> {
        walletHolder.walletStatePublisher
            .flatMap { state -> AnyPublisher<MetadataState, WalletAssetFetchError> in
                guard let metadata = state?.metadata else {
                    return .failure(.notInitialized)
                }
                return .just(metadata)
            }
            .receive(on: queue)
            .flatMap { [metadataService] metadataState -> AnyPublisher<Entry, WalletAssetFetchError> in
                metadataService.fetchEntry(with: metadataState)
                    .mapError(WalletAssetFetchError.fetchFailed)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func save<Node: MetadataNodeEntry>(node: Node) -> AnyPublisher<EmptyValue, WalletAssetSaveError> {
        walletHolder.walletStatePublisher
            .flatMap { state -> AnyPublisher<MetadataState, WalletAssetSaveError> in
                guard let metadata = state?.metadata else {
                    return .failure(.notInitialized)
                }
                return .just(metadata)
            }
            .receive(on: queue)
            .logMessageOnOutput(logger: logger, message: { _ in
                "About to save metadata entry: \(node)"
            })
            .flatMap { [metadataService, logger] metadataState -> AnyPublisher<EmptyValue, WalletAssetSaveError> in
                metadataService.save(node: node, state: metadataState)
                    .logMessageOnOutput(logger: logger, message: { _ in
                        "Metadata entry saved"
                    })
                    .mapError(WalletAssetSaveError.saveFailed)
                    .map { _ in .noValue }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
