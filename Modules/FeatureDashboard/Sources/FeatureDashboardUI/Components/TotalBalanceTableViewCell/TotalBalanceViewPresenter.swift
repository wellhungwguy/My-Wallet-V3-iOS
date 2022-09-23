// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift

final class TotalBalanceViewPresenter {

    // MARK: - Properties

    let titleContent: LabelContent

    // MARK: - Services

    let balancePresenter: AssetPriceViewPresenter
    let pieChartPresenter: AssetPieChartPresenter

    // MARK: - Setup

    init(
        coincore: CoincoreAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        app: AppProtocol
    ) {
        let balanceInteractor = PortfolioBalanceChangeProvider(
            coincore: coincore,
            fiatCurrencyService: fiatCurrencyService
        )
        let chartInteractor = AssetPieChartInteractor(
            coincore: coincore,
            fiatCurrencyService: fiatCurrencyService,
            app: app
        )
        pieChartPresenter = AssetPieChartPresenter(
            edge: 88,
            interactor: chartInteractor
        )
        balancePresenter = AssetPriceViewPresenter(
            interactor: balanceInteractor,
            descriptors: .balance
        )

        let titleString = app.currentMode == .universal
            ? LocalizationConstants.Dashboard.Portfolio.totalBalance
            : LocalizationConstants.Dashboard.Portfolio.balance

        titleContent = LabelContent(
            text: titleString,
            font: .main(.medium, 16),
            color: .mutedText,
            accessibility: .id(Accessibility.Identifier.Dashboard.TotalBalanceCell.titleLabel)
        )
    }

    func refresh() {
        balancePresenter.refresh()
        pieChartPresenter.refresh()
    }
}

extension PortfolioBalanceChangeProvider: AssetPriceViewInteracting {
    var state: Observable<DashboardAsset.State.AssetPrice.Interaction> {
        changeObservable
            .map { state in
                switch state {
                case .calculating,
                     .invalid:
                    return .loading
                case .value(let change):
                    return .loaded(
                        next: .init(
                            currentPrice: change.balance,
                            time: .hours(24),
                            changePercentage: change.changePercentage?.doubleValue,
                            priceChange: change.change
                        )
                    )
                }
            }
    }

    func refresh() {
        refreshBalance()
    }
}
