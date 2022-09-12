// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import RxSwift

class WalletServiceMock: WalletOptionsAPI {

    var underlyingWalletOptions: WalletOptions = .empty
    var walletOptions: Single<WalletOptions> {
        .just(underlyingWalletOptions)
    }
}

extension WalletOptions {
    static var empty: WalletOptions {
        WalletOptions(domains: nil, hotWalletAddresses: nil, xlmExchangeAddresses: nil, xlmMetadata: nil)
    }
}
