// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import WalletCore

func getMultiAddress(
    xpubs: [XPub],
    fetchMultiAddressFor: FetchMultiAddressFor
) -> AnyPublisher<[AddressItem], Error> {
    fetchMultiAddressFor(xpubs)
        .map(\.addresses)
        .map { addresses in
            addresses.map(AddressItem.init(response:))
        }
        .eraseError()
        .eraseToAnyPublisher()
}

struct AddressItem: Hashable {
    let xpub: String
    let accountIndex: Int
    let changeIndex: Int
}

extension AddressItem {

    init(response: BitcoinChainAddressResponse) {
        self.xpub = response.address
        self.accountIndex = response.accountIndex
        self.changeIndex = response.changeIndex
    }
}
