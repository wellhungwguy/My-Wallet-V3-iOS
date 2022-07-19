// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct AddressBookEntryResponse: Codable, Equatable {
    let addr: String
    let label: String
}

extension WalletPayloadKit.AddressBookEntry {
    static func from(model: AddressBookEntryResponse) -> AddressBookEntry {
        AddressBookEntry(
            addr: model.addr,
            label: model.label
        )
    }

    var toAddressBookEntryResponse: AddressBookEntryResponse {
        AddressBookEntryResponse(
            addr: addr,
            label: label
        )
    }
}
