// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import MoneyKit

public enum StakingRepositoryError: Error {
    case ineligible
    case networkError(NetworkError)
}

public protocol StakingBalanceRepositoryAPI {

    func getAllBalances(fiatCurrency: FiatCurrency) -> AnyPublisher<StakingAccountBalances, StakingRepositoryError>

    func invalidateAllBalances()
}
