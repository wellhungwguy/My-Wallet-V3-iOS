// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct LinkToken: Equatable {
    public let linkToken: String
    public let tokenExpiresAt: String

    public init(linkToken: String, tokenExpiresAt: String) {
        self.linkToken = linkToken
        self.tokenExpiresAt = tokenExpiresAt
    }
}
