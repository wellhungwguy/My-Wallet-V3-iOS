// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public protocol DelegatedCustodyAccount {
    var coin: CryptoCurrency { get }
    var publicKey: Data { get }
}
