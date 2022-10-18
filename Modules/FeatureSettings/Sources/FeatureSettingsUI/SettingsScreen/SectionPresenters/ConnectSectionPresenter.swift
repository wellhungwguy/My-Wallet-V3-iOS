// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift

final class ConnectSectionPresenter: SettingsSectionPresenting {

    typealias State = SettingsSectionLoadingState

    let sectionType: SettingsSectionType = .connect

    var state: Observable<State> {
        let presenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.ExchangeConnect.title),
            interactor: DefaultBadgeAssetInteractor(initialState: .loaded(next: .launch)),
            title: LocalizationConstants.Settings.Badge.blockchainExchange
        )
        let state = State.loaded(next:
            .some(
                .init(
                    sectionType: sectionType,
                    items: [.init(cellType: .badge(.pitConnection, presenter))]
                )
            )
        )

        return .just(state)
    }

    init() {}
}
