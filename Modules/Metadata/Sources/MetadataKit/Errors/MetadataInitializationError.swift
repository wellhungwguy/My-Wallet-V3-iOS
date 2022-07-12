// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MetadataInitialisationError: Error, Equatable {
    case failedToDeriveSecondPasswordNode(DeriveSecondPasswordNodeError)
    case failedToLoadRemoteMetadataNode(LoadRemoteMetadataError)
    case failedToDecodeRemoteMetadataNode(DecodingError)
    case failedToDeriveRemoteMetadataNode(MetadataInitError)
    case failedToGenerateNodes(Error)

    public static func == (lhs: MetadataInitialisationError, rhs: MetadataInitialisationError) -> Bool {
        switch (lhs, rhs) {
        case (.failedToDeriveSecondPasswordNode(let leftError), .failedToDeriveSecondPasswordNode(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        case (.failedToLoadRemoteMetadataNode(let leftError), .failedToLoadRemoteMetadataNode(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        case (.failedToDecodeRemoteMetadataNode(let leftError), .failedToDecodeRemoteMetadataNode(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        case (.failedToDeriveRemoteMetadataNode(let leftError), .failedToDeriveRemoteMetadataNode(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        case (.failedToGenerateNodes(let leftError), .failedToGenerateNodes(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        default:
            return false
        }
    }
}
