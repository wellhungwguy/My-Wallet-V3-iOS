// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain

// TODO: make this internal by refactoring NabuAuthenticationExecutor (put that in FeatureAuthentication)
public struct NabuOfflineTokenResponse: Decodable, Equatable {

    enum CodingKeys: String, CodingKey {
        case userId
        case token
        case created
        case userCredentialsId
        case mercuryLifetimeToken
    }

    public let userId: String
    public let token: String
    public let created: Bool?

    // Unified account recovery
    public let userCredentialsId: String?
    public let mercuryLifetimeToken: String?

    public init(
        userId: String,
        token: String,
        created: Bool? = nil,
        userCredentialsId: String? = nil,
        mercuryLifetimeToken: String? = nil
    ) {
        self.userId = userId
        self.token = token
        self.created = created
        self.userCredentialsId = userCredentialsId
        self.mercuryLifetimeToken = mercuryLifetimeToken
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.token = try container.decode(String.self, forKey: .token)
        self.created = try container.decodeIfPresent(Bool.self, forKey: .created)
        self.userCredentialsId = try container.decodeIfPresent(String.self, forKey: .userCredentialsId)
        self.mercuryLifetimeToken = try container.decodeIfPresent(String.self, forKey: .mercuryLifetimeToken)
    }

    public init(from token: NabuOfflineToken) {
        self.init(
            userId: token.userId,
            token: token.token,
            created: token.created,
            userCredentialsId: token.exchangeUserId,
            mercuryLifetimeToken: token.exchangeOfflineToken
        )
    }
}

extension NabuOfflineToken {

    public init(from response: NabuOfflineTokenResponse) {
        self.init(
            userId: response.userId,
            token: response.token,
            exchangeUserId: response.userCredentialsId,
            exchangeOfflineToken: response.mercuryLifetimeToken,
            created: response.created
        )
    }
}
