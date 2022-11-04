// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import ToolKit

public protocol CurrentBalanceCellInteracting: AnyObject {
    var assetBalanceViewInteractor: AssetBalanceViewInteracting { get }
    var accountType: SingleAccountType { get }
}

public final class CurrentBalanceCellInteractor: CurrentBalanceCellInteracting {

    public let accountType: SingleAccountType
    public let assetBalanceViewInteractor: AssetBalanceViewInteracting

    public init(account: BlockchainAccount) {
        assetBalanceViewInteractor = AccountBalanceViewInteractor(
            account: account
        )
        switch account {
        case is CryptoInterestAccount,
             is CryptoStakingAccount:
            accountType = .custodial(.savings)
        case is TradingAccount,
             is FiatAccount:
            accountType = .custodial(.trading)
        case is CryptoNonCustodialAccount:
            accountType = .nonCustodial
        default:
            unimplemented("Unsupported account type: \(String(reflecting: account))")
        }
    }
}
