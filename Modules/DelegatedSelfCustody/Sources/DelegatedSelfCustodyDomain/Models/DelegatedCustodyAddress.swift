// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct DelegatedCustodyAddress: Equatable {
    public let accountIndex: Int
    public let address: String
    public let format: String
    public let includesMemo: Bool
    public let isDefault: Bool
    public let publicKey: String

    public init(
        accountIndex: Int,
        address: String,
        format: String,
        includesMemo: Bool,
        isDefault: Bool,
        publicKey: String
    ) {
        self.accountIndex = accountIndex
        self.address = address
        self.format = format
        self.includesMemo = includesMemo
        self.isDefault = isDefault
        self.publicKey = publicKey
    }
}
