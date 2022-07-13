//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol TransactionRestrictionsProviderAPI {
    /// Returns the maximum number of transactions the user can perform for the specified action, if there's a limit, or `nil` otherwise.
    func maximumNumbersOfTransactions(for action: AssetAction) -> Int?
}
