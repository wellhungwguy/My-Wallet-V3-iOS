// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import Foundation
import ToolKit

/// Model encapsulating the network response from the `/auth` endpoint.
public struct NabuSessionTokenResponse {
    public let identifier: String
    public let userId: String
    public let token: String
    public let isActive: Bool
    public let expiresAt: Date?

    public init(
        identifier: String,
        userId: String,
        token: String,
        isActive: Bool,
        expiresAt: Date?
    ) {
        self.identifier = identifier
        self.userId = userId
        self.token = token
        self.isActive = isActive
        self.expiresAt = expiresAt
    }
}

extension NabuSessionTokenResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case userId
        case token
        case isActive
        case expiresAt
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decode(String.self, forKey: .identifier)
        self.userId = try values.decode(String.self, forKey: .userId)
        self.token = try values.decode(String.self, forKey: .token)
        self.isActive = try values.decode(Bool.self, forKey: .isActive)
        let expiresAtString = try values.decode(String.self, forKey: .expiresAt)
        self.expiresAt = DateFormatter.sessionDateFormat.date(from: expiresAtString)
    }
}

extension NabuSessionToken {
    init(from response: NabuSessionTokenResponse) {
        self.init(
            identifier: response.identifier,
            userId: response.userId,
            token: response.token,
            isActive: response.isActive,
            expiresAt: response.expiresAt
        )
    }
}
