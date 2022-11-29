// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct DeviceVerificationDetails: Decodable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case location = "country_name"
        case browser
        case ipAddress = "ip_address"
    }

    public let originLocation: String
    public let originIP: String
    public let originBrowser: String

    public init(
        originLocation: String,
        originIP: String,
        originBrowser: String
    ) {
        self.originLocation = originLocation
        self.originIP = originIP
        self.originBrowser = originBrowser
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.originLocation = try container.decode(String.self, forKey: .location)
        self.originIP = try container.decode(String.self, forKey: .ipAddress)
        self.originBrowser = try container.decode(String.self, forKey: .browser)
    }
}
