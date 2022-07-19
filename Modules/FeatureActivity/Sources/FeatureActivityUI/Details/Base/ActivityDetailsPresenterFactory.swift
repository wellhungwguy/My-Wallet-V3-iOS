// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ERC20Kit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

enum ActivityDetailsPresenterFactory {

    static func presenter(
        for event: ActivityItemEvent,
        router: ActivityRouterAPI
    ) -> DetailsScreenPresenterAPI {
        switch event {
        case .interest(let interest):
            return InterestActivityDetailsPresenter(event: interest)
        case .fiat(let fiat):
            return FiatActivityDetailsPresenter(event: fiat)
        case .crypto(let crypto):
            return CryptoActivityDetailsPresenter(event: crypto)
        case .buySell(let event):
            let interactor = BuySellActivityDetailsInteractor(
                cardDataService: resolve(),
                ordersService: resolve()
            )
            return BuySellActivityDetailsPresenter(
                event: event,
                interactor: interactor,
                analyticsRecorder: resolve()
            )
        case .swap(let swap):
            return SwapActivityDetailsPresenter(event: swap)
        case .transactional(let transactional):
            return Self.presenter(
                transactional: transactional,
                router: router
            )
        case .simpleTransactional(let event):
            let interactor = SimpleActivityDetailsInteractor(
                fiatCurrencySettings: resolve(),
                priceService: resolve()
            )
            return SimpleActivityDetailsPresenter(
                event: event,
                interactor: interactor,
                alertViewPresenter: resolve(),
                analyticsRecorder: resolve()
            )
        }
    }

    private static func presenter(
        transactional: TransactionalActivityItemEvent,
        router: ActivityRouterAPI
    ) -> DetailsScreenPresenterAPI {
        switch transactional.currency {
        case .bitcoin:
            return BitcoinActivityDetailsPresenter(event: transactional, router: router)
        case .bitcoinCash:
            return BitcoinCashActivityDetailsPresenter(event: transactional, router: router)
        case .stellar:
            return StellarActivityDetailsPresenter(event: transactional, router: router)
        case .ethereum, .polygon:
            let interactor = EthereumActivityDetailsInteractor(cryptoCurrency: transactional.currency)
            return EthereumActivityDetailsPresenter(event: transactional, router: router, interactor: interactor)
        case let asset where asset.isERC20:
            let interactor = ERC20ActivityDetailsInteractor(cryptoCurrency: transactional.currency)
            return ERC20ActivityDetailsPresenter(event: transactional, router: router, interactor: interactor)
        default:
            fatalError("Transactional Activity Details not implemented for \(transactional.currency.code).")
        }
    }
}
