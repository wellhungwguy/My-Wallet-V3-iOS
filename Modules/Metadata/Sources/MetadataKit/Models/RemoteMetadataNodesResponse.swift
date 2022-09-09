// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct RemoteMetadataNodesResponse: MetadataNodeEntry, Codable {

    var areAllMetadataNodesAvailable: Bool {
        metadata != nil
    }

    static var type: EntryType = .root

    var metadata: String?
}
