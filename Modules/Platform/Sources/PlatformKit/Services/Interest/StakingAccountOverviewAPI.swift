//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit

public protocol StakingAccountOverviewAPI {
    func invalidateAccountBalances()
    func balance(
        for currency: CryptoCurrency
    ) -> AnyPublisher<CustodialAccountBalanceState, Never>
}
