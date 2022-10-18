// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct LinkAccountInfo: Equatable {
    public let id: String
    public let linkToken: String

    public init(id: String, linkToken: String) {
        self.id = id
        self.linkToken = linkToken
    }
}
