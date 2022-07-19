// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit
import RxRelay
import RxSwift

/// A `BadgeCellPresenting` class for showing the user's preferred local currency
final class PreferredCurrencyCellPresenter: BadgeCellPresenting {

    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell

    // MARK: - Properties

    let accessibility: Accessibility = .id(AccessibilityId.Currency.title)
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    var isLoading: Bool {
        isLoadingRelay.value
    }

    // MARK: - Private Properties

    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(interactor: PreferredCurrencyBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.Badge.walletDisplayCurrency,
            descriptors: .settings
        )
        badgeAssetPresenting = PreferredCurrencyBadgePresenter(
            interactor: interactor
        )

        badgeAssetPresenting.state
            .map(\.isLoading)
            .bindAndCatch(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}

/// A `BadgeCellPresenting` class for showing the user's preferred local currency
final class PreferredTradingCurrencyCellPresenter: BadgeCellPresenting {

    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell

    // MARK: - Properties

    let accessibility: Accessibility = .id(AccessibilityId.Currency.title)
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    var isLoading: Bool {
        isLoadingRelay.value
    }

    // MARK: - Private Properties

    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(interactor: PreferredTradingCurrencyBadgeInteractor) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.Badge.tradingCurrency,
            descriptors: .settings
        )
        badgeAssetPresenting = PreferredCurrencyBadgePresenter(
            interactor: interactor
        )

        badgeAssetPresenting.state
            .map(\.isLoading)
            .bindAndCatch(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}
