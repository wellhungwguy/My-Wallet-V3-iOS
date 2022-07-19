// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    public static var featureTransactionDomain = module {

        factory { CryptoTargetPayloadFactory() as CryptoTargetPayloadFactoryAPI }

        factory { AvailableTradingPairsService() as AvailableTradingPairsServiceAPI }

        factory { BlockchainNameResolutionService() as BlockchainNameResolutionServiceAPI }

        factory { () -> CryptoCurrenciesServiceAPI in
            CryptoCurrenciesService(
                pairsService: DIKit.resolve(),
                priceService: DIKit.resolve()
            )
        }

        factory { PaymentAccountsService() as FeatureTransactionDomain.PaymentAccountsServiceAPI }

        factory { () -> TransactionLimitsServiceAPI in
            TransactionLimitsService(
                repository: DIKit.resolve(),
                conversionService: DIKit.resolve(),
                walletCurrencyService: DIKit.resolve()
            )
        }

        factory { () -> WithdrawalServiceAPI in
            WithdrawalService(
                client: DIKit.resolve(),
                transactionLimitsService: DIKit.resolve()
            )
        }

        factory { HotWalletAddressService() as HotWalletAddressServiceAPI }

        factory { QuotesEngine() as QuotesEngineAPI }
    }
}
