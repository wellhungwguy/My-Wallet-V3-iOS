// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct DelegatedCustodyDerivation {
    let currencyCode: String
    let derivationPath: String
    let style: String

    init(currencyCode: String, derivationPath: String, style: String) {
        self.currencyCode = currencyCode
        self.derivationPath = derivationPath
        self.style = style
    }

    init(response: DelegatedCustodyDerivationResponse.Item) {
        self.init(
            currencyCode: response.code,
            derivationPath: "m/\(response.purpose)'/\(response.coinType)'/0'/0/0",
            style: response.style
        )
    }
}

struct DelegatedCustodyDerivationResponse: Decodable {

    static let empty = DelegatedCustodyDerivationResponse(assets: [])

    struct Item: Decodable {
        let code: String
        let purpose: String
        let coinType: String
        let style: String
    }

    let assets: [Item]
}
