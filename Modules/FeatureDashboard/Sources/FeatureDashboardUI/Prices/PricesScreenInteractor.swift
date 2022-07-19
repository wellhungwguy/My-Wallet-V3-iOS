// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class PricesScreenInteractor {

    // MARK: - Properties

    var enabledCryptoCurrencies: Observable<[CryptoCurrency]> {
        guard !showSupportedPairsOnly else {
            return supportedPairsInteractorService.fetchSupportedCryptoCurrenciesForTrading()
        }
        return Observable.combineLatest(
            supportedPairsInteractorService.fetchSupportedCryptoCurrenciesForTrading(),
            marketCapService.marketCaps().asObservable()
        )
        .map { [enabledCurrenciesService] tradingCurrencies, marketCaps -> [CryptoCurrency] in
            enabledCurrenciesService.allEnabledCryptoCurrencies.map { currency in
                (currency: currency, marketCap: marketCaps[currency.code] ?? 0)
            }
            .sorted { $0.currency.name < $1.currency.name }
            .sorted { $0.marketCap > $1.marketCap }
            .map(\.currency)
            .sorted(like: tradingCurrencies)
        }
    }

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let priceService: PriceServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI
    private let marketCapService: MarketCapServiceAPI
    private let showSupportedPairsOnly: Bool

    // MARK: - Init

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        marketCapService: MarketCapServiceAPI = resolve(),
        showSupportedPairsOnly: Bool
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
        self.marketCapService = marketCapService
        self.showSupportedPairsOnly = showSupportedPairsOnly
    }

    // MARK: - Methods

    func assetPriceViewInteractor(
        for currency: CryptoCurrency
    ) -> AssetPriceViewInteracting {
        AssetPriceViewDailyInteractor(
            cryptoCurrency: currency,
            priceService: priceService,
            fiatCurrencyService: fiatCurrencyService
        )
    }

    func refresh() {}
}
