// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol MetadataServiceAPI {

    /// Fetches and initialises the root metadata node
    /// - Parameters:
    ///   - credentials: the wallet credentials
    ///   - masterKey: the wallet root key
    ///   - payloadIsDoubleEncrypted: is the wallet payload double encrypted
    /// - Returns: A `Publisher` of root metadata state or error
    func initialize(
        credentials: Credentials,
        masterKey: MasterKey,
        payloadIsDoubleEncrypted: Bool
    ) -> AnyPublisher<MetadataState, MetadataInitialisationError>

    /// Fetches and initialises the root metadata node using a mnemonic phrase
    /// and recovers the wallet credentials
    /// - Parameters:
    ///   - mnemonic: A seed phrase of the wallet to be recovered
    /// - Returns: A `Publisher` of root metadata state and wallet credentials or error
    func initializeAndRecoverCredentials(
        from mnemonic: String
    ) -> AnyPublisher<RecoveryContext, MetadataInitialisationAndRecoveryError>

    /// Fetches a the specified metadata entry
    /// - Parameters:
    ///   - type: the type of metadata entry to fetch
    ///   - state: the root metadata state
    /// - Returns: A `Publisher` of the JSON string of the node or error
    func fetch(
        type: EntryType,
        state: MetadataState
    ) -> AnyPublisher<String, MetadataFetchError>

    /// Saves the given entry
    /// - Parameters:
    ///   - jsonPayload: The JSON string of the payload
    ///   - metadataType: the type of metadata entry to save
    /// - Returns: A `Publisher` of `Void` or error
    func save(
        node jsonPayload: String,
        metadataType: EntryType,
        state: MetadataState
    ) -> AnyPublisher<Void, MetadataSaveError>
}

extension MetadataServiceAPI {

    /// Fetches a the specified metadata entry
    /// - Parameters:
    ///   - type: the type of metadata entry to fetch
    ///   - state: the root metadata state
    /// - Returns: A `Publisher` of the encoded node or error
    public func fetch<Entry: Decodable>(
        type: EntryType,
        with state: MetadataState
    ) -> AnyPublisher<Entry, MetadataFetchError> {
        fetch(type: type, state: state)
            .decodeEntry()
            .eraseToAnyPublisher()
    }

    /// Fetches a the specified metadata entry
    /// - Parameters:
    ///   - entry: The Entry type to fetch
    ///   - state: The root metadata state
    /// - Returns: A `Publisher` of the encoded node or error
    public func fetch<Entry: MetadataNodeEntry>(
        entry: Entry.Type,
        with state: MetadataState
    ) -> AnyPublisher<Entry, MetadataFetchError> {
        fetch(type: Entry.type, state: state)
            .decodeEntry()
            .eraseToAnyPublisher()
    }

    /// Fetches a the specified metadata entry
    /// - Parameters:
    ///   - state: the root metadata state
    /// - Returns: A `Publisher` of the encoded node or error
    public func fetchEntry<Entry: MetadataNodeEntry>(
        with state: MetadataState
    ) -> AnyPublisher<Entry, MetadataFetchError> {
        fetch(type: Entry.type, state: state)
            .decodeEntry()
            .eraseToAnyPublisher()
    }

    /// Saves the given entry
    /// - Parameters:
    ///   - node: the encoded node
    ///   - state: the root metadata state
    /// - Returns: A `Publisher` of `Void` or error
    public func save(
        node: some Encodable,
        metadataType: EntryType,
        state: MetadataState
    ) -> AnyPublisher<Void, MetadataSaveError> {
        encodeEntryToJSONString(entry: node)
            .flatMap { jsonPayload -> AnyPublisher<Void, MetadataSaveError> in
                save(
                    node: jsonPayload,
                    metadataType: metadataType,
                    state: state
                )
            }
            .eraseToAnyPublisher()
    }

    /// Saves the given entry
    /// - Parameters:
    ///   - node: the encoded node
    ///   - state: the root metadata state
    /// - Returns: A `Publisher` of `Void` or error
    public func save<Node: MetadataNodeEntry>(
        node: Node,
        state: MetadataState
    ) -> AnyPublisher<Void, MetadataSaveError> {
        encodeEntryToJSONString(entry: node)
            .flatMap { jsonPayload -> AnyPublisher<Void, MetadataSaveError> in
                save(
                    node: jsonPayload,
                    metadataType: Node.type,
                    state: state
                )
            }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == String, Failure: FromDecodingError {

    func decodeEntry<Entry: Decodable>() -> AnyPublisher<Entry, Failure> {
        flatMap { jsonString -> AnyPublisher<Entry, Failure> in
            decodeJSONStringToEntry(jsonString: jsonString)
        }
        .eraseToAnyPublisher()
    }
}

private func decodeJSONStringToEntry<Entry: Decodable, E: FromDecodingError>(
    jsonString: String
) -> AnyPublisher<Entry, E> {
    jsonString.decodeJSON(to: Entry.self)
        .mapError(E.from)
        .publisher
        .eraseToAnyPublisher()
}

private func encodeEntryToJSONString<E: FromEncodingError>(
    entry: some Encodable
) -> AnyPublisher<String, E> {
    entry.encodeToJSONString()
        .mapError(E.from)
        .publisher
        .eraseToAnyPublisher()
}
