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

    public func getAllCryptoAssetsInfo() async -> [AssetBalanceInfo] {
        let assets = coincore.cryptoAssets
        let appMode = await app.mode()
        var assetsInfo: [AssetBalanceInfo] = []
        for asset in assets {
            async let accountGroup = try? await asset.accountGroup(filter: appMode.filter).await()
            async let fiatCurrency = try? await fiatCurrencyService.displayCurrency.await()
            let balance = try? await accountGroup?.balance.await()
            let currencyType = balance?.currencyType

            if let accountGroup = await accountGroup,
                let fiatCurrency = await fiatCurrency,
                let balance,
                let currencyType,
                let cryptoCurrency = currencyType.cryptoCurrency
            {

                async let fiatBalance = try? await accountGroup.balancePair(fiatCurrency: fiatCurrency).await()
                async let prices = try? await priceService.priceSeries(of: cryptoCurrency, in: fiatCurrency, within: .day()).await()

                assetsInfo.append(await AssetBalanceInfo(
                    cryptoBalance: balance,
                    fiatBalance: fiatBalance,
                    currency: currencyType,
                    delta: prices?.deltaPercentage.roundTo(places: 2)
                ))
            }
        }
        return assetsInfo
    }

    public func getFiatAssetsInfo() async -> AssetBalanceInfo? {
        let asset = coincore.fiatAsset
        if let accountGroup = try? await asset.accountGroup(filter: .all).await(),
           let fiatCurrency = try? await fiatCurrencyService.displayCurrency.await(),
           let account = accountGroup.accounts.first(where: { account in
               account.currencyType.fiatCurrency == fiatCurrency
           }),
           let balance = try? await account.balance.await()
        {

            let fiatBalance = try? await account.balancePair(fiatCurrency: fiatCurrency).await()

            return AssetBalanceInfo(
                cryptoBalance: balance,
                fiatBalance: fiatBalance,
                currency: account.currencyType,
                delta: nil
            )
        }
        return nil
    }

    public func getAllCryptoAssetsInfoPublisher() -> AnyPublisher<[AssetBalanceInfo], Never> {
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
