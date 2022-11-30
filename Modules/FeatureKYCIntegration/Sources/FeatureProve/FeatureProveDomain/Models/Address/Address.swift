// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Address: Equatable, Codable {

    public let line1: String?
    public let line2: String?
    public let city: String?
    public let postCode: String?
    public let state: String?
    public let country: String?

    public init(
        line1: String? = nil,
        line2: String? = nil,
        city: String? = nil,
        postCode: String? = nil,
        state: String? = nil,
        country: String?
    ) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.postCode = postCode
        self.state = state
        self.country = country
    }
}
