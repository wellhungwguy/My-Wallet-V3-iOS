// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

/// A simple struct that defines an account in terms of whether funds are stored within Blockchain's domain or are extenally sourced.
public struct LimitsAccount: Hashable {

    public enum LimitsAccountType: String {
        case custodial = "CUSTODIAL"
        case nonCustodial = "NON_CUSTODIAL"
    }

    public let currency: CurrencyType
    public let accountType: LimitsAccountType

    public init(currency: CurrencyType, accountType: LimitsAccountType) {
        self.currency = currency
        self.accountType = accountType
    }
}
