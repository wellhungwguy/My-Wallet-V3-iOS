// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain

extension DelegatedCustodyAddress {
    static func create(from response: AddressesResponse) -> [DelegatedCustodyAddress] {
        response.results.reduce(into: [DelegatedCustodyAddress]()) { partialResult, result in
            partialResult.append(
                contentsOf: result.addresses.map { address in
                    DelegatedCustodyAddress(address: address, account: result.account)
                }
            )
        }
    }

    init(address: AddressesResponse.Address, account: AddressesResponse.Account) {
        self.init(
            accountIndex: account.index,
            address: address.address,
            format: address.format,
            includesMemo: address.includesMemo,
            isDefault: address.default,
            publicKey: address.pubKey
        )
    }
}
