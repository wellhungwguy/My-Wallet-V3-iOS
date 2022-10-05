// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import FeatureSettingsDomain
import PlatformKit
import RxSwift
import ToolKit

final class ProfileSectionPresenter: SettingsSectionPresenting {

    // MARK: - SettingsSectionPresenting

    let sectionType: SettingsSectionType = .profile
    var state: Observable<SettingsSectionLoadingState>

    private let limitsPresenter: TierLimitsCellPresenter
    private let emailVerificationPresenter: EmailVerificationCellPresenter
    private let mobileVerificationPresenter: MobileVerificationCellPresenter
    private let cardIssuingPresenter: CardIssuingCellPresenter

    init(
        tiersLimitsProvider: TierLimitsProviding,
        emailVerificationInteractor: EmailVerificationBadgeInteractor,
        mobileVerificationInteractor: MobileVerificationBadgeInteractor,
        cardIssuingInteractor: CardIssuingBadgeInteractor,
        cardIssuingAdapter: CardIssuingAdapterAPI
    ) {
        limitsPresenter = TierLimitsCellPresenter(tiersProviding: tiersLimitsProvider)
        emailVerificationPresenter = .init(interactor: emailVerificationInteractor)
        mobileVerificationPresenter = .init(interactor: mobileVerificationInteractor)
        cardIssuingPresenter = .init(interactor: cardIssuingInteractor)
        // IOS: 4806: Hiding the web log in for production build as pair wallet with QR code has been deprecated
        // Web log in is enabled in internal production to ease QA testing
        var viewModel = SettingsSectionViewModel(
            sectionType: sectionType,
            items: [
                .init(cellType: .badge(.limits, limitsPresenter)),
                .init(cellType: .clipboard(.walletID)),
                .init(cellType: .badge(.emailVerification, emailVerificationPresenter)),
                .init(cellType: .badge(.mobileVerification, mobileVerificationPresenter)),
                .init(cellType: .common(.webLogin))
            ]
        )

        let cardIssuingCellModelDisplay = SettingsCellViewModel(
            cellType: .common(.cardIssuing)
        )
        let cardIssuingCellModelOrder = SettingsCellViewModel(
            cellType: .badge(.cardIssuing, cardIssuingPresenter)
        )

        state = cardIssuingAdapter
            .isEnabled()
            .flatMap { isEnabled -> AnyPublisher<SettingsSectionLoadingState, Never> in
                if let index = viewModel.items.firstIndex(of: cardIssuingCellModelDisplay) {
                    viewModel.items.remove(at: index)
                }

                if let index = viewModel.items.firstIndex(of: cardIssuingCellModelOrder) {
                    viewModel.items.remove(at: index)
                }

                guard isEnabled else { return .just(.loaded(next: .some(viewModel))) }

                return cardIssuingAdapter
                    .hasCard()
                    .map { hasCard -> SettingsSectionLoadingState in
                        switch hasCard {
                        case true:
                            viewModel.items.append(cardIssuingCellModelDisplay)
                        case false:
                            viewModel.items.append(cardIssuingCellModelOrder)
                        }

                        return .loaded(next: .some(viewModel))
                    }
                    .eraseToAnyPublisher()
            }
            .asObservable()
    }
}
