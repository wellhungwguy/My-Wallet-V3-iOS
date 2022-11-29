// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import MoneyKit
import ToolKit

public protocol HistoricalFiatPriceProviding: AnyObject {

    /// Returns the service that matches the `CryptoCurrency`
    subscript(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI { get }
    func refresh(window: PriceWindow)
}

final class HistoricalFiatPriceProvider: HistoricalFiatPriceProviding {

    subscript(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI {
        retrieveOrCreate(currency: currency)
    }

    // MARK: - Services

    private let services: Atomic<[CryptoCurrency: HistoricalFiatPriceServiceAPI]>
    private let exchangeProvider: ExchangeProviding
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    // MARK: - Setup

    init(
        exchangeProvider: ExchangeProviding = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.services = Atomic([:])
        self.exchangeProvider = exchangeProvider
        self.fiatCurrencyService = fiatCurrencyService
    }

    func refresh(window: PriceWindow) {
        services.value.values.forEach { service in
            service.fetchTriggerRelay.accept(window)
        }
    }

    private func retrieveOrCreate(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI {
        services.mutateAndReturn { services -> HistoricalFiatPriceServiceAPI in
            if let service = services[currency] {
                return service
            }
            let service = HistoricalFiatPriceService(
                cryptoCurrency: currency,
                pairExchangeService: exchangeProvider[currency],
                fiatCurrencyService: fiatCurrencyService
            )
            services[currency] = service
            return service
        }
    }
}
