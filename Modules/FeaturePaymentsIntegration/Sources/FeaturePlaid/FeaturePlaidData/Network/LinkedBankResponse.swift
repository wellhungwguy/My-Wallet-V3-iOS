// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeaturePlaidDomain

public struct LinkedBankResponse: Decodable {
    let id: String
    let partner: String
    let state: LinkedBankState
}
