// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import MoneyKit
import ToolKit

/// A provider for exchange rates as per supported crypto.
public protocol ExchangeProviding: AnyObject {

    /// Returns the exchange service
    subscript(currency: Currency) -> PairExchangeServiceAPI { get }

    /// Refreshes all the exchange rates
    func refresh()
}

final class ExchangeProvider: ExchangeProviding {

    // MARK: - Subscript

    subscript(currency: Currency) -> PairExchangeServiceAPI {
        retrieveOrCreate(currency: currency.currencyType)
    }

    // MARK: - Private Properties

    private let services: Atomic<[CurrencyType: PairExchangeServiceAPI]>
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    // MARK: - Init

    init(fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        self.services = Atomic([:])
        self.fiatCurrencyService = fiatCurrencyService
    }

    // MARK: - Methods

    func refresh() {
        services.value.values.forEach { service in
            service.fetchTriggerRelay.accept(())
        }
    }

    // MARK: - Private Methods

    private func retrieveOrCreate(currency: CurrencyType) -> PairExchangeServiceAPI {
        services.mutateAndReturn { services -> PairExchangeServiceAPI in
            if let service = services[currency] {
                return service
            }
            let service = PairExchangeService(
                currency: currency,
                fiatCurrencyService: fiatCurrencyService
            )
            services[currency] = service
            return service
        }
    }
}
