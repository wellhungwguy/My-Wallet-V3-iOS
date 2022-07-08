// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import RxSwift

public protocol FiatCurrencySelectionProviderAPI {
    var currencies: Observable<[FiatCurrency]> { get }
}

public final class DefaultFiatCurrencySelectionProvider: FiatCurrencySelectionProviderAPI {
    public let currencies: Observable<[FiatCurrency]>

    public init(availableCurrencies: [FiatCurrency] = FiatCurrency.supported) {
        currencies = .just(availableCurrencies)
    }
}

public final class FiatTradingCurrencySelectionProvider: FiatCurrencySelectionProviderAPI {
    public let currencies: Observable<[FiatCurrency]>

    public init(userService: NabuUserServiceAPI = resolve()) {
        currencies = userService.fetchUser().map(\.currencies.usableFiatCurrencies).asObservable()
    }
}
