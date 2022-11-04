// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import ToolKit

public protocol StakingAccountServiceAPI: StakingAccountOverviewAPI {
}

final class StakingAccountService: StakingAccountServiceAPI {

    private let balanceRepository: StakingBalanceRepositoryAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let priceService: PriceServiceAPI

    init(
        balanceRepository: StakingBalanceRepositoryAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve()
    ) {
        self.balanceRepository = balanceRepository
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiersService = kycTiersService
        self.priceService = priceService
    }

    func balance(
        for currency: CryptoCurrency
    ) -> AnyPublisher<CustodialAccountBalanceState, Never> {
        stakingAccountsBalance()
            .map(CustodialAccountBalanceStates.init)
            .map(\.[currency.currencyType])
            .eraseToAnyPublisher()
    }

    func invalidateAccountBalances() {
        balanceRepository.invalidateAllBalances()
    }

    private func stakingAccountsBalance() -> AnyPublisher<StakingAccountBalances, Never> {
        let isTier2Approved = kycTiersService.tiers
            .map(\.isTier2Approved)
            .eraseError()
        let displayCurrency = fiatCurrencyService
            .displayCurrency
            .eraseError()
        return isTier2Approved
            .zip(displayCurrency)
            .flatMap { [balanceRepository] isTier2Approved, displayCurrency
                -> AnyPublisher<StakingAccountBalances, Error> in
                guard isTier2Approved else {
                    return .just(.empty)
                }
                return balanceRepository.getAllBalances(fiatCurrency: displayCurrency)
                    .eraseError()
            }
            .replaceError(with: .empty)
            .eraseToAnyPublisher()
    }
}
