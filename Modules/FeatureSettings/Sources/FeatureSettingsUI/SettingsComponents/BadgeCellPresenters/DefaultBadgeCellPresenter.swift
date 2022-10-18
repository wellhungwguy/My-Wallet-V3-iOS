// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import Localization
import PlatformUIKit
import RxRelay
import RxSwift

final class DefaultBadgeCellPresenter: BadgeCellPresenting {

    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell

    // MARK: - Properties

    let accessibility: Accessibility
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    var isLoading: Bool {
        isLoadingRelay.value
    }

    // MARK: - Private Properties

    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        accessibility: Accessibility,
        labelContentPresenting: LabelContentPresenting,
        badgeAssetPresenting: BadgeAssetPresenting
    ) {
        self.accessibility = accessibility
        self.labelContentPresenting = labelContentPresenting
        self.badgeAssetPresenting = badgeAssetPresenting
        badgeAssetPresenting.state
            .map(\.isLoading)
            .bindAndCatch(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }

    convenience init(
        accessibility: Accessibility,
        interactor: BadgeAssetInteracting,
        title: String,
        descriptors: DefaultLabelContentPresenter.Descriptors = .settings
    ) {
        let labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: title,
            descriptors: descriptors
        )
        let badgeAssetPresenting = DefaultBadgeAssetPresenter(
            interactor: interactor
        )
        self.init(
            accessibility: accessibility,
            labelContentPresenting: labelContentPresenting,
            badgeAssetPresenting: badgeAssetPresenting
        )
    }
}
