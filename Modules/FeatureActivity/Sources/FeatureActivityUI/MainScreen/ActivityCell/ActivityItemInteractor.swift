// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit

final class ActivityItemInteractor {

    let event: ActivityItemEvent
    let balanceViewInteractor: AssetBalanceViewInteracting

    init(activityItemEvent: ActivityItemEvent, pairExchangeService: PairExchangeServiceAPI) {
        self.event = activityItemEvent
        switch activityItemEvent {
        case .buySell(let buySellActivityItem) where buySellActivityItem.isBuy:
            self.balanceViewInteractor = SimpleBalanceViewInteractor(
                fiatValue: activityItemEvent.inputAmount,
                cryptoValue: buySellActivityItem.outputValue
            )
        case .buySell(let buySellActivityItem) where !buySellActivityItem.isBuy:
            self.balanceViewInteractor = SimpleBalanceViewInteractor(
                fiatValue: buySellActivityItem.outputValue,
                cryptoValue: activityItemEvent.inputAmount
            )
        case .fiat(let fiatActivityItem):
            self.balanceViewInteractor = SimpleBalanceViewInteractor(
                fiatValue: .init(fiatValue: fiatActivityItem.amount),
                cryptoValue: nil
            )
        default:
            self.balanceViewInteractor = ActivityItemBalanceViewInteractor(
                activityItemBalanceFetching: ActivityItemBalanceFetcher(
                    pairExchangeService: pairExchangeService,
                    moneyValue: activityItemEvent.inputAmount,
                    at: event.creationDate
                )
            )
        }
    }
}
