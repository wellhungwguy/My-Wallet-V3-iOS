// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct MobileAuthInfo: Equatable {
    public let id: String
    public let phone: String?

    public init(id: String, phone: String?) {
        self.id = id
        self.phone = phone
    }
}
