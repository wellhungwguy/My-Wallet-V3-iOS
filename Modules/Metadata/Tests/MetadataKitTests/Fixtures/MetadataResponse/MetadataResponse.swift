// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import MetadataDataKit
@testable import MetadataKit
import TestKit

extension MetadataResponse {

    static func fetchMagicResponse(
        for address: String
    ) -> MetadataResponse? {
        let name = "fetch_magic_metadata_response_" + address
        return Fixtures.load(
            name: name,
            in: .module
        )
    }

    static var credentialsEntryMetadataResponse: MetadataResponse {
        Fixtures.load(name: "wallet_credentials_entry_response", in: .module)!
    }

    static var ethereumFetchMagicMetadataResponse: MetadataResponse {
        fetchMagicResponse(for: "129GLwNB2EbNRrGMuNSRh9PM83xU2Mpn81")!
    }

    static var ethereumEntryMetadataResponse: MetadataResponse {
        Fixtures.load(name: "ethereum_entry_response", in: .module)!
    }

    static var rootMetadataResponse: MetadataResponse {
        Fixtures.load(name: "root_metadata_response", in: .module)!
    }

    static var erroneousRootMetadataResponse: MetadataResponse {
        Fixtures.load(name: "erroneous_root_metadata_response", in: .module)!
    }
}
