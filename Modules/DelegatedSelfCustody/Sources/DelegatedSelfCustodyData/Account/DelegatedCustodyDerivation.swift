// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct DelegatedCustodyDerivation {
    let currencyCode: String
    let derivationPath: String
    let style: String

    static var stacks: DelegatedCustodyDerivation {
        .init(currencyCode: "STX", derivationPath: "m/44'/5757'/0'/0/0", style: "SINGLE")
    }
}
