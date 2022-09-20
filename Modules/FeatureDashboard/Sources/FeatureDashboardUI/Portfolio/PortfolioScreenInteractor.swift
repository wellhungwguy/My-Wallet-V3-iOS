// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit
import WalletPayloadKit

public final class PortfolioScreenInteractor {
    typealias CurrencyBalance = (currency: CryptoCurrency, hasBalance: Bool)

    // MARK: - Properties

    let fiatBalancesInteractor: FiatBalanceCollectionViewInteractor

    var enabledCryptoCurrencies: [CryptoCurrency] {
        coincore.cryptoAssets.map(\.asset)
    }

    // MARK: - Private Properties

    private let coincore: CoincoreAPI
    private let disposeBag = DisposeBag()
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let historicalProvider: HistoricalFiatPriceProviding
    private let reactiveWallet: ReactiveWalletAPI
    private let userPropertyInteractor: AnalyticsUserPropertyInteracting
    private var historicalBalanceCellInteractors: [CryptoCurrency: HistoricalBalanceCellInteractor] = [:]
    private var app: AppProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        historicalProvider: HistoricalFiatPriceProviding = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        reactiveWallet: ReactiveWalletAPI = resolve(),
        userPropertyInteractor: AnalyticsUserPropertyInteracting = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.coincore = coincore
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
        self.historicalProvider = historicalProvider
        self.reactiveWallet = reactiveWallet
        self.userPropertyInteractor = userPropertyInteractor
        fiatBalancesInteractor = FiatBalanceCollectionViewInteractor()
        self.app = app

        NotificationCenter
            .when(.walletInitialized) { [weak self] _ in
                self?.refresh()
            }
    }

    // MARK: - Methods

    var appMode: Observable<AppMode> {
        app.modePublisher().asObservable()
    }

    var cryptoCurrencies: Observable<CurrencyBalance> {
        let cryptoStreams: [Observable<CurrencyBalance>] =
            coincore
                .cryptoAssets
                .map { cryptoAsset -> Observable<CurrencyBalance> in
                    let currency = cryptoAsset.asset

                    return app.modePublisher()
                        .flatMap { appMode in
                            cryptoAsset
                                .accountGroup(filter: appMode.filter)
                        }
                        .eraseError()
                        .flatMap { group -> AnyPublisher<Bool, Error> in
                            guard let group = group else {
                                return .just(false)
                                    .eraseToAnyPublisher()
                            }
                            return group
                                .balance
                                .flatMap { [weak self] moneyValue -> AnyPublisher<Bool, Error> in
                                    let appMode = self?.app.currentMode
                                    if appMode == .defi,
                                        case .crypto(let currency) = group.currencyType,
                                        currency.isCoin
                                    {
                                        return .just(true)
                                    }
                                    return .just(moneyValue.hasPositiveDisplayableBalance)
                                }
                                .eraseError()
                        }
                        .map { hasPositiveDisplayableBalance -> CurrencyBalance in
                            (currency, hasPositiveDisplayableBalance)
                        }
                        .asObservable()
                        .catchAndReturn((currency, false))
                }
        return Observable
            .merge(cryptoStreams)
            .compactMap { $0 }
    }

    func historicalBalanceCellInteractor(
        for cryptoCurrency: CryptoCurrency
    ) -> HistoricalBalanceCellInteractor? {
        if let interactor = historicalBalanceCellInteractors[cryptoCurrency] {
            return interactor
        }
        let cryptoAsset = coincore[cryptoCurrency]
        let interactor = HistoricalBalanceCellInteractor(
            cryptoAsset: cryptoAsset,
            historicalFiatPriceService: historicalProvider[cryptoAsset.asset],
            fiatCurrencyService: fiatCurrencyService
        )
        historicalBalanceCellInteractors[cryptoCurrency] = interactor
        return interactor
    }

    func refresh() {
        reactiveWallet.waitUntilInitializedFirst
            .asSingle()
            .subscribe(onSuccess: { [weak self] _ in
                self?.refreshAfterReactiveWallet()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods

    private func refreshAfterReactiveWallet() {
        for interactor in historicalBalanceCellInteractors.values {
            interactor.refresh()
        }
        // Record user properties once wallet is initialized
        userPropertyInteractor.record()
    }
}
