// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCurrencies: [CurrencyType] { get }
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    /// This returns the supported currencies that a user can link a bank through a partner, eg Yodlee
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { get }
}
