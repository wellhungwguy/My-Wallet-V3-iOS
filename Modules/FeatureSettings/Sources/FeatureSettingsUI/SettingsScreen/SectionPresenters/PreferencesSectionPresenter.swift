// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class PreferencesSectionPresenter: SettingsSectionPresenting {

    // MARK: - SettingsSectionPresenting

    let sectionType: SettingsSectionType = .preferences

    var state: Observable<SettingsSectionLoadingState>

    private let emailNotificationsCellPresenter: EmailNotificationsSwitchCellPresenter
    private let preferredCurrencyCellPresenter: PreferredCurrencyCellPresenter
    private let preferredTradingCurrencyCellPresenter: PreferredTradingCurrencyCellPresenter

    init(
        emailNotificationService: EmailNotificationSettingsServiceAPI,
        preferredCurrencyBadgeInteractor: PreferredCurrencyBadgeInteractor,
        preferredTradingCurrencyBadgeInteractor: PreferredTradingCurrencyBadgeInteractor,
        featureFlagService: FeatureFlagsServiceAPI = resolve()
    ) {
        emailNotificationsCellPresenter = .init(service: emailNotificationService)
        preferredCurrencyCellPresenter = .init(interactor: preferredCurrencyBadgeInteractor)
        preferredTradingCurrencyCellPresenter = .init(interactor: preferredTradingCurrencyBadgeInteractor)

        var viewModel = SettingsSectionViewModel(
            sectionType: sectionType,
            items: [
                .init(cellType: .switch(.emailNotifications, emailNotificationsCellPresenter)),
                .init(cellType: .badge(.currencyPreference, preferredCurrencyCellPresenter)),
                .init(cellType: .badge(.tradingCurrencyPreference, preferredTradingCurrencyCellPresenter))
            ]
        )

        state = featureFlagService
            .isEnabled(AppFeature.notificationPreferences)
            .last()
            .map { notificationPreferencesEnabled -> SettingsSectionLoadingState in
                let notificationPreferencesCell: SettingsCellViewModel = .init(cellType: .common(.notifications))
                if notificationPreferencesEnabled, viewModel.items.contains(notificationPreferencesCell) == false {
                    viewModel.items.append(notificationPreferencesCell)
                    viewModel.items.remove(at: 0)
                }
                return .loaded(next: .some(viewModel))
            }
            .asObservable()
    }
}
