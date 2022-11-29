// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class HistoricalBalanceCellInteractor {

    // MARK: - Properties

    let sparklineInteractor: SparklineInteracting
    let priceInteractor: AssetPriceViewInteracting
    let balanceInteractor: AssetBalanceViewInteracting
    let historicalFiatPriceService: HistoricalFiatPriceServiceAPI
    let cryptoCurrency: CryptoCurrency
    let evmNetwork: EVMNetwork?

    // MARK: - Setup

    init(
        cryptoAsset: CryptoAsset,
        historicalFiatPriceService: HistoricalFiatPriceServiceAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI
    ) {
        cryptoCurrency = cryptoAsset.asset
        self.historicalFiatPriceService = historicalFiatPriceService
        sparklineInteractor = SparklineInteractor(
            priceService: historicalFiatPriceService,
            cryptoCurrency: cryptoCurrency
        )
        priceInteractor = AssetPriceViewHistoricalInteractor(
            historicalPriceProvider: historicalFiatPriceService
        )
        balanceInteractor = AccountAssetBalanceViewInteractor(
            cryptoAsset: cryptoAsset,
            fiatCurrencyService: fiatCurrencyService
        )
        evmNetwork = cryptoCurrency.assetModel.kind.erc20ParentChain.flatMap { erc20ParentChain in
            enabledCurrenciesService.allEnabledEVMNetworks
               .first(where: { $0.networkConfig.networkTicker == erc20ParentChain })
        }
    }

    func refresh() {
        historicalFiatPriceService.fetchTriggerRelay.accept(.day(.oneHour))
        balanceInteractor.refresh()
    }
}
