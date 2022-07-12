// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataFetchError: FromDecodingError, Equatable {
    case loadMetadataError(LoadRemoteMetadataError)
    case failedToDeriveMetadataNode(MetadataNodeError)
    case decodingError(DecodingError)

    public static func from(_ decodingError: DecodingError) -> Self {
        .decodingError(decodingError)
    }

    public static func == (lhs: MetadataFetchError, rhs: MetadataFetchError) -> Bool {
        switch (lhs, rhs) {
        case (.loadMetadataError(let leftError), .loadMetadataError(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        case (.failedToDeriveMetadataNode(let leftError), .failedToDeriveMetadataNode(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        case (.decodingError(let leftError), .decodingError(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        default:
            return false
        }
    }
}
