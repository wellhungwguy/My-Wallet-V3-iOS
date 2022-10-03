// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct LinkedBankState: NewTypeString {
    public let value: String
    public init(_ value: String) { self.value = value }

    public static let pending: Self = "PENDING"
    public static let active: Self = "ACTIVE"
    public static let blocked: Self = "BLOCKED"
}
