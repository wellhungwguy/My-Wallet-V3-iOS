// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

public struct AddressCache: Equatable {
    public let receiveAccount: String?
    public let changeAccount: String?

    public init(
        receiveAccount: String?,
        changeAccount: String?
    ) {
        self.receiveAccount = receiveAccount
        self.changeAccount = changeAccount
    }
}

/// Creates AdressCache from the given node
/// - Parameter node: A `PrivateKey` to derive the accounts
/// - Returns: An `AddressCache`
func createAddressCache(from node: PrivateKey) -> AddressCache {
    AddressCache(
        receiveAccount: node.derive(at: .normal(0)).xpub,
        changeAccount: node.derive(at: .normal(1)).xpub
    )
}
