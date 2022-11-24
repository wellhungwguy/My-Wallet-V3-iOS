// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxRelay
import RxSwift
import RxToolKit

final class FiatCurrencySettingsServiceMock: FiatCurrencySettingsServiceAPI {

    private let displayCurrencyRelay: BehaviorRelay<FiatCurrency>
    private let tradingCurrencyRelay: BehaviorRelay<FiatCurrency>

    var supportedFiatCurrencies: AnyPublisher<Set<FiatCurrency>, Never> {
        .just([.EUR, .GBP, .USD])
    }

    var displayCurrencyPublisher: AnyPublisher<FiatCurrency, Never> {
        displayCurrencyRelay
            .asObservable()
            .asPublisher()
            .replaceError(with: .USD)
            .eraseToAnyPublisher()
    }

    var tradingCurrencyPublisher: AnyPublisher<FiatCurrency, Never> {
        tradingCurrencyRelay
            .asObservable()
            .asPublisher()
            .replaceError(with: .USD)
            .eraseToAnyPublisher()
    }

    var displayCurrencyObservable: Observable<FiatCurrency> {
        displayCurrencyPublisher.asObservable()
    }

    func update(displayCurrency: FiatCurrency, context: FlowContext) -> AnyPublisher<Void, CurrencyUpdateError> {
        displayCurrencyRelay.accept(displayCurrency)
        return .just(())
    }

    func update(tradingCurrency: FiatCurrency, context: FlowContext) -> AnyPublisher<Void, CurrencyUpdateError> {
        tradingCurrencyRelay.accept(tradingCurrency)
        return .just(())
    }

    init(expectedCurrency: FiatCurrency, expectedTradingCurrency: FiatCurrency? = nil) {
        self.displayCurrencyRelay = BehaviorRelay(value: expectedCurrency)
        self.tradingCurrencyRelay = BehaviorRelay(value: expectedTradingCurrency ?? expectedCurrency)
    }
}
