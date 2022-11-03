// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import Foundation
import RxSwift

final class ReferralSectionPresenter: SettingsSectionPresenting {

    // MARK: - SettingsSectionPresenting

    let sectionType: SettingsSectionType = .referral
    var state: Observable<SettingsSectionLoadingState>

    init(
        refferalAdapter: ReferralAdapterAPI
    ) {
        var viewModel = SettingsSectionViewModel(
            sectionType: sectionType,
            items: []
        )

        state = refferalAdapter
            .hasReferral()
            .map { referral -> SettingsSectionLoadingState in
                if let referral {
                    let cellViewModel = ReferralTableViewCellViewModel(referral: referral)
                    let referralCellModelDisplay = SettingsCellViewModel(cellType: .refferal(.referral, cellViewModel))
                    if !viewModel.items.contains(referralCellModelDisplay) {
                        viewModel.items.append(referralCellModelDisplay)
                    }
                    return .loaded(next: .some(viewModel))
                } else {
                    return .loaded(next: .empty)
                }
            }
            .asObservable()
    }
}
