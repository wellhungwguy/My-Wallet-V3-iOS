// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MoneyDomainKit

class MockEnabledCurrenciesService: EnabledCurrenciesServiceAPI {
    var allEnabledCurrencies: [CurrencyType] = []
    var allEnabledCryptoCurrencies: [CryptoCurrency] = []
    var allEnabledFiatCurrencies: [FiatCurrency] = []
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] = []
}
