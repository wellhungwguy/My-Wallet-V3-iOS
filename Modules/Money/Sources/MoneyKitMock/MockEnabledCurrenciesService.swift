// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MoneyKit

class MockEnabledCurrenciesService: EnabledCurrenciesServiceAPI {
    var allEnabledCurrencies: [CurrencyType] = []
    var allEnabledCryptoCurrencies: [CryptoCurrency] = []
    var allEnabledFiatCurrencies: [FiatCurrency] = []
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] = []
}
