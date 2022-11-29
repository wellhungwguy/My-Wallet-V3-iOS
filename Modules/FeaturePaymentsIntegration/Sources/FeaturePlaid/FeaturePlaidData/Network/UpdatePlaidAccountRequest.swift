// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct UpdatePlaidAccountRequest: Encodable {
    public let attributes: Attributes

    public init(
        accountId: String,
        publicToken: String
    ) {
        self.attributes = Attributes(
            accountId: accountId,
            publicToken: publicToken
        )
    }
}

extension UpdatePlaidAccountRequest {
    public struct Attributes: Encodable {
        public let accountId: String
        public let publicToken: String

        enum CodingKeys: String, CodingKey {
            case accountId = "account_id"
            case publicToken = "public_token"
        }

        public init(
            accountId: String,
            publicToken: String
        ) {
            self.accountId = accountId
            self.publicToken = publicToken
        }
    }
}
