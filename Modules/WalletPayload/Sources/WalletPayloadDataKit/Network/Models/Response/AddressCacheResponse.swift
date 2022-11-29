// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct AddressCacheResponse: Equatable, Codable {
    let receiveAccount: String?
    let changeAccount: String?

    static let empty = AddressCacheResponse(receiveAccount: "", changeAccount: "")
}

extension WalletPayloadKit.AddressCache {
    static func from(model: AddressCacheResponse) -> AddressCache {
        AddressCache(
            receiveAccount: model.receiveAccount,
            changeAccount: model.changeAccount
        )
    }

    var toAddressCacheResponse: AddressCacheResponse {
        AddressCacheResponse(
            receiveAccount: receiveAccount,
            changeAccount: changeAccount
        )
    }
}
