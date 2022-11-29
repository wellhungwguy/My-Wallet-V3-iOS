// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import ToolKit

public class AllCryptoAssetsService: AllCryptoAssetsServiceAPI {
    private let coincore: CoincoreAPI
    private let app: AppProtocol
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let priceService: PriceServiceAPI

    public init(
        coincore: CoincoreAPI,
        app: AppProtocol,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        priceService: PriceServiceAPI
    ) {
        self.coincore = coincore
        self.app = app
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
    }

    public func getAllCryptoAssetsInfo() async -> [CryptoAssetInfo] {
        let assets = coincore.cryptoAssets
        let appMode = await app.mode()
        var assetsInfo: [CryptoAssetInfo] = []
        for asset in assets {
            async let accountGroup = try? await asset.accountGroup(filter: appMode.filter).await()
            async let fiatCurrency = try? await fiatCurrencyService.displayCurrency.await()
            let balance = try? await accountGroup?.balance.await()
            let cryptoCurrency = balance?.currencyType.cryptoCurrency

            if let accountGroup = await accountGroup,
                let fiatCurrency = await fiatCurrency,
                let balance,
                let cryptoCurrency
            {

                async let fiatBalance = try? await accountGroup.balancePair(fiatCurrency: fiatCurrency).await()
                async let prices = try? await priceService.priceSeries(of: cryptoCurrency, in: fiatCurrency, within: .day()).await()

                assetsInfo.append(await CryptoAssetInfo(
                    cryptoBalance: balance,
                    fiatBalance: fiatBalance,
                    currency: cryptoCurrency,
                    delta: prices?.deltaPercentage.roundTo(places: 2)
                ))
            }
        }
        return assetsInfo
    }

    public func getAllCryptoAssetsInfoPublisher() -> AnyPublisher<[CryptoAssetInfo], Never> {
           Deferred { [self] in
               Future { promise in
                   Task {
                       do {
                           promise(.success(await self.getAllCryptoAssetsInfo()))
                       }
                   }
               }
           }
           .eraseToAnyPublisher()
       }
}
