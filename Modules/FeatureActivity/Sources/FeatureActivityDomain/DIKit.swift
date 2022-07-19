// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    public static var featureActivityDomain = module {

        factory { () -> TransactionDetailServiceAPI in
            TransactionDetailService(
                blockchainAPI: DIKit.resolve()
            )
        }

        factory { () -> ActivityServiceContaining in
            ActivityServiceContainer(
                exchangeProviding: DIKit.resolve(),
                fiatCurrency: DIKit.resolve(),
                selectionService: DIKit.resolve()
            )
        }

        factory { () -> WalletPickerSelectionServiceAPI in
            WalletPickerSelectionService(
                coincore: DIKit.resolve()
            )
        }

        // MARK: Public

        factory { () -> BuySellActivityItemEventServiceAPI in
            BuySellActivityItemEventService(
                ordersService: DIKit.resolve(),
                kycTiersService: DIKit.resolve()
            )
        }
    }
}
