// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

public protocol WithdrawalLocksServiceAPI {
    var withdrawalLocks: AnyPublisher<WithdrawalLocks, Never> { get }
}

final class WithdrawalLocksService: WithdrawalLocksServiceAPI {
    var withdrawalLocks: AnyPublisher<WithdrawalLocks, Never>

    init(
        repository: WithdrawalLocksRepositoryAPI = resolve(),
        fiatCurrencyCodePublisher: FiatCurrencyCodeProviderAPI = resolve()
    ) {
        self.withdrawalLocks = fiatCurrencyCodePublisher.defaultFiatCurrencyCode
            .flatMap { currencyCode in
                repository.withdrawalLocks(currencyCode: currencyCode)
            }
            .removeDuplicates()
            .shareReplay()
    }
}
