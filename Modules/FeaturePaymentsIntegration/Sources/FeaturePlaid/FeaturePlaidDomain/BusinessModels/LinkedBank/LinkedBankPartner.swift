// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct LinkedBankPartner: NewTypeString {
    public let value: String
    public init(_ value: String) { self.value = value }

    public static let yodlee: Self = "YODLEE"
    public static let yapily: Self = "YAPILY"
    public static let plaid: Self = "PLAID"
    public static let none: Self = "NONE"
}
