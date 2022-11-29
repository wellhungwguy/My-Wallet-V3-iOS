// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Model describing credentials for interacting with the Veriff API
public struct VeriffCredentials: Codable {
    public let applicantId: String
    public let key: String
    public let url: String

    private enum CodingKeys: String, CodingKey {
        case applicantId
        case key = "token"
        case data
        case url
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let nested = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.applicantId = try values.decode(String.self, forKey: .applicantId)
        self.key = try values.decode(String.self, forKey: .key)
        self.url = try nested.decode(String.self, forKey: .url)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nested = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)

        try container.encode(applicantId, forKey: .applicantId)
        try container.encode(key, forKey: .key)
        try nested.encode(url, forKey: .url)
    }
}
