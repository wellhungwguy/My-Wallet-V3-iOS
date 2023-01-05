// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct ProveConfig: Equatable, Codable {

    public let country: String
    public let state: String?

    public init(
        country: String,
        state: String? = nil
    ) {
        self.country = country
        self.state = state
    }
}
