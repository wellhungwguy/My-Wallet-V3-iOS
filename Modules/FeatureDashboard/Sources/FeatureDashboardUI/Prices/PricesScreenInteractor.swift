// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
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

        func filteredCryptoCurrencies(for appMode: AppMode) -> [CryptoCurrency] {
            enabledCurrenciesService
                .allEnabledCryptoCurrencies
                .filter { currency in
                    if appMode == .defi {
                        return currency.supports(product: .privateKey)
                    }

                    if appMode == .trading {
                        return currency.supports(product: .custodialWalletBalance) || currency.supports(product: .interestBalance)
                    }
                    return true
                }
        }

        return Observable.combineLatest(
            supportedPairsInteractorService.fetchSupportedCryptoCurrenciesForTrading(),
            marketCapService.marketCaps().asObservable(),
            app.modePublisher().asObservable()
        )
        .map { tradingCurrencies, marketCaps, appMode -> [CryptoCurrency] in
            filteredCryptoCurrencies(for: appMode)
                .map { currency in
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
    private let app: AppProtocol

    // MARK: - Init

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        marketCapService: MarketCapServiceAPI = resolve(),
        app: AppProtocol = resolve(),
        showSupportedPairsOnly: Bool
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
        self.marketCapService = marketCapService
        self.app = app
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
