// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

struct DelegatedCustodyAccount: Equatable {
    let coin: CryptoCurrency
    let derivationPath: String
    let style: String
    let publicKey: Data
    let privateKey: Data
}
