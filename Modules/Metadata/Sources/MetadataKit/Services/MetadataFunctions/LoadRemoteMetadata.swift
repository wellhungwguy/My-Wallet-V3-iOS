// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

typealias LoadRemoteMetadata =
    (MetadataNode) -> AnyPublisher<String, LoadRemoteMetadataError>

public enum LoadRemoteMetadataError: LocalizedError {
    case notYetCreated
    case networkError(NetworkError)
    case decryptionFailed(DecryptMetadataError)

    public var errorDescription: String? {
        switch self {
        case .notYetCreated:
            return "Metadata entry not yet created"
        case .networkError(let networkError):
            guard let code = networkError.code else {
                return "Unknown network error"
            }
            return "Error Code: \(code)"
        case .decryptionFailed(let decryptMetadataError):
            return decryptMetadataError.errorDescription
        }
    }
}

func provideLoadRemoteMetadata(
    fetch: @escaping FetchMetadataEntry
) -> LoadRemoteMetadata {
    { metadataNode in
        loadRemoteMetadata(
            metadataNode: metadataNode,
            fetchMetadataEntry: fetch
        )
    }
}

private func loadRemoteMetadata(
    metadataNode: MetadataNode,
    fetchMetadataEntry: FetchMetadataEntry
) -> AnyPublisher<String, LoadRemoteMetadataError> {
    fetchMetadataEntry(metadataNode.address)
        .catch { networkError -> AnyPublisher<MetadataPayload, LoadRemoteMetadataError> in
            guard networkError.is404 else {
                return .failure(.networkError(networkError))
            }
            return .failure(.notYetCreated)
        }
        .flatMap { metadataPayload -> AnyPublisher<String, LoadRemoteMetadataError> in
            decryptMetadata(metadata: metadataNode, payload: metadataPayload.payload)
                .publisher
                .mapError(LoadRemoteMetadataError.decryptionFailed)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}
