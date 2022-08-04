// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import MetadataDataKit
@testable import MetadataKit
import TestKit

extension MetadataPayload {

    static var credentialsMetadataEntryPayload: MetadataPayload {
        MetadataPayload(from: MetadataResponse.credentialsEntryMetadataResponse)
    }

    static var ethereumMetadataEntryPayload: MetadataPayload {
        MetadataPayload(from: MetadataResponse.ethereumEntryMetadataResponse)
    }

    static var rootMetadataPayload: MetadataPayload {
        MetadataPayload(
            from: MetadataResponse.rootMetadataResponse
        )
    }

    static var erroreousRootMetadataPayload: MetadataPayload {
        MetadataPayload(
            from: MetadataResponse.erroneousRootMetadataResponse
        )
    }
}
