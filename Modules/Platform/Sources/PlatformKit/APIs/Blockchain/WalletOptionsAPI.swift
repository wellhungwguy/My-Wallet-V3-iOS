// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

public protocol WalletOptionsAPI {
    var walletOptions: Single<WalletOptions> { get }
}
