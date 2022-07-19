// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct AddressesResponse: Decodable {
    struct Address: Decodable {
        let address: String
        let `default`: Bool
        let format: String
        let includesMemo: Bool
        let pubKey: String
    }

    struct Account: Decodable {
        let index: Int
        let name: String
    }

    struct Result: Decodable {
        let addresses: [Address]
        let account: Account
    }

    let results: [Result]
}
