// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import RxRelay
import RxSwift
import ToolKit

/// The calculation state of Simple Buy supported pairs
public typealias BuyCryptoSupportedPairsCalculationState = ValueCalculationState<SupportedPairs>

/// A Simple Buy Service that provides the supported pairs for the current Fiat Currency.
public protocol SupportedPairsInteractorServiceAPI: AnyObject {

    var pairs: Observable<SupportedPairs> { get }

    func fetch() -> Observable<SupportedPairs>
    func fetchSupportedCryptoCurrenciesForTrading() -> Observable<[CryptoCurrency]>
}

final class SupportedPairsInteractorService: SupportedPairsInteractorServiceAPI {

    // MARK: - Public properties

    var pairs: Observable<SupportedPairs> {
        pairsRelay
            .flatMap(weak: self) { (self, pairs) -> Observable<SupportedPairs> in
                guard let pairs = pairs else {
                    return self.fetch()
                }
                return .just(pairs)
            }
            .distinctUntilChanged()
    }

    // MARK: - Private properties

    private let pairsRelay = BehaviorRelay<SupportedPairs?>(value: nil)

    private let pairsService: SupportedPairsServiceAPI
    private let fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI

    private var onTradingCurrency: AnyCancellable?

    // MARK: - Setup

    init(
        app: AppProtocol = resolve(),
        pairsService: SupportedPairsServiceAPI = resolve(),
        fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI = resolve()
    ) {
        self.pairsService = pairsService
        self.fiatCurrencySettingsService = fiatCurrencySettingsService

        NotificationCenter.when(.logout) { [weak pairsRelay] _ in
            pairsRelay?.accept(nil)
        }

        onTradingCurrency = app.on(blockchain.user.currency.preferred.fiat.trading.currency) { [weak pairsRelay] _ in
            pairsRelay?.accept(nil)
        }
        .subscribe()
    }

    func fetch() -> Observable<SupportedPairs> {
        fiatCurrencySettingsService
            .tradingCurrencyPublisher
            .asObservable()
            .map { .only(fiatCurrency: $0) }
            .flatMapLatest(weak: self) { (self, value) in
                self.pairsService.fetchPairs(for: value).asObservable()
            }
            .do(onNext: { [weak self] pairs in
                self?.pairsRelay.accept(pairs)
            })
    }

    func fetchSupportedCryptoCurrenciesForTrading() -> Observable<[CryptoCurrency]> {
        pairs
            .map(\.cryptoCurrencies)
            .flatMap { [pairsService] cryptoCurrencies -> Observable<[CryptoCurrency]> in
                guard cryptoCurrencies.isEmpty else {
                    return .just(cryptoCurrencies)
                }
                return pairsService
                    .fetchSupportedTradingCryptoCurrencies()
                    .asObservable()
            }
    }
}
