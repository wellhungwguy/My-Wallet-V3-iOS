// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import WalletPayloadKit

final class PortfolioScreenInteractor {

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

    // MARK: - Init

    init(
        historicalProvider: HistoricalFiatPriceProviding = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        reactiveWallet: ReactiveWalletAPI = resolve(),
        userPropertyInteractor: AnalyticsUserPropertyInteracting = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.coincore = coincore
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
        self.historicalProvider = historicalProvider
        self.reactiveWallet = reactiveWallet
        self.userPropertyInteractor = userPropertyInteractor
        fiatBalancesInteractor = FiatBalanceCollectionViewInteractor()

        NotificationCenter.when(.walletInitialized) { [weak self] _ in
            self?.refresh()
        }
    }

    // MARK: - Methods

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
            .asObservable()
            .take(1)
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
