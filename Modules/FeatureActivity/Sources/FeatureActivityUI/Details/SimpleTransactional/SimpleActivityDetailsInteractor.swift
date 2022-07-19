// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit

final class SimpleActivityDetailsInteractor {

    // MARK: - Private Properties

    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI

    // MARK: - Init

    init(
        fiatCurrencySettings: FiatCurrencySettingsServiceAPI,
        priceService: PriceServiceAPI
    ) {
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
    }

    // MARK: - Public Functions

    func details(
        event: SimpleTransactionalActivityItemEvent
    ) -> AnyPublisher<SimpleActivityDetailsViewModel, Never> {
        fiatCurrencySettings
            .displayCurrency
            .flatMap { [priceService] fiatCurrency -> AnyPublisher<PriceQuoteAtTime?, Never> in
                priceService.price(
                    of: event.currency,
                    in: fiatCurrency,
                    at: .time(event.creationDate)
                )
                .optional()
                .replaceError(with: nil)
                .eraseToAnyPublisher()
            }
            .map { priceQuoteAtTime -> SimpleActivityDetailsViewModel in
                SimpleActivityDetailsViewModel(
                    with: event,
                    price: priceQuoteAtTime?.moneyValue.fiatValue
                )
            }
            .eraseToAnyPublisher()
    }
}
