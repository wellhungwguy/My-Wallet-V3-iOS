// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct PlaidAccountAttributes: Equatable {
    public let accountId: String
    public let publicToken: String

    public init(accountId: String, publicToken: String) {
        self.accountId = accountId
        self.publicToken = publicToken
    }
}
