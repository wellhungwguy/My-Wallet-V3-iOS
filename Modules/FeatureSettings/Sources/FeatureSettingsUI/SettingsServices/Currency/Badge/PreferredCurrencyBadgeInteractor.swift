// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class PreferredCurrencyBadgeInteractor: DefaultBadgeAssetInteractor {

    // MARK: - Setup

    init(app: AppProtocol = resolve()) {
        super.init()

        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .map { currency -> DefaultBadgeAssetInteractor.InteractionState in
                if let currency = currency.value {
                    let title = "\(currency.name) (\(currency.displaySymbol))"
                    return .loaded(
                        next: BadgeItem(
                            type: .default(accessibilitySuffix: title),
                            description: title
                        )
                    )
                } else {
                    return .loading
                }
            }
            .asObservable()
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

final class PreferredTradingCurrencyBadgeInteractor: DefaultBadgeAssetInteractor {

    // MARK: - Setup

    init(app: AppProtocol = resolve()) {
        super.init()

        app.publisher(for: blockchain.user.currency.preferred.fiat.trading.currency, as: FiatCurrency.self)
            .map { currency -> DefaultBadgeAssetInteractor.InteractionState in
                if let currency = currency.value {
                    let title = "\(currency.name) (\(currency.displaySymbol))"
                    return .loaded(
                        next: BadgeItem(
                            type: .default(accessibilitySuffix: title),
                            description: title
                        )
                    )
                } else {
                    return .loading
                }
            }
            .asObservable()
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
