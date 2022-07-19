// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain
import Foundation
import MoneyKit

struct Account: Equatable, DelegatedCustodyAccount {
    let coin: CryptoCurrency
    let derivationPath: String
    let style: String
    let publicKey: Data
    let privateKey: Data
}
