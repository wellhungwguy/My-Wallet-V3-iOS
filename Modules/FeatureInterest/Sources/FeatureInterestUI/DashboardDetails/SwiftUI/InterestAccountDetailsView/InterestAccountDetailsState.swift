// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureInterestDomain
import MoneyKit
import PlatformKit

struct InterestAccountDetailsState: Equatable {

    struct InterestAccountActionSelection: Equatable {
        let currency: CurrencyType
        let action: AssetAction
    }

    var isLoading: Bool = true
    var supportedActions: [AssetAction] = []
    var interestAccountActionSelection: InterestAccountActionSelection?
    var interestAccountBalanceSummary: InterestAccountOverviewBalanceSummary?
    var interestAccountRowItems: IdentifiedArrayOf<InterestAccountOverviewRowItem> {
        IdentifiedArrayOf(uniqueElements: interestAccountOverview.items)
    }

    var currency: CurrencyType {
        interestAccountOverview.currency
    }

    var interestAccountOverview: InterestAccountOverview

    init(interestAccountOverview: InterestAccountOverview) {
        self.interestAccountOverview = interestAccountOverview
    }
}
