// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class ProfileSectionPresenter: SettingsSectionPresenting {

    // MARK: - SettingsSectionPresenting

    let sectionType: SettingsSectionType = .profile
    var state: Observable<SettingsSectionLoadingState>

    private let limitsPresenter: BadgeCellPresenting
    private let emailVerificationPresenter: BadgeCellPresenting
    private let mobileVerificationPresenter: BadgeCellPresenting
    private let cardIssuingPresenter: BadgeCellPresenting

    init(
        tiersLimitsProvider: TierLimitsProviding,
        emailVerificationInteractor: EmailVerificationBadgeInteractor,
        mobileVerificationInteractor: MobileVerificationBadgeInteractor,
        cardIssuingInteractor: CardIssuingBadgeInteractor,
        blockchainDomainsAdapter: BlockchainDomainsAdapter,
        cardIssuingAdapter: CardIssuingAdapterAPI
    ) {
        self.limitsPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.AccountLimits.title),
            interactor: TierLimitsBadgeInteractor(limitsProviding: tiersLimitsProvider),
            title: LocalizationConstants.KYC.accountLimits
        )
        self.emailVerificationPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Email.title),
            interactor: emailVerificationInteractor,
            title: LocalizationConstants.Settings.Badge.email
        )
        self.mobileVerificationPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.Mobile.title),
            interactor: mobileVerificationInteractor,
            title: LocalizationConstants.Settings.Badge.mobileNumber
        )
        self.cardIssuingPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.CardIssuing.title),
            interactor: cardIssuingInteractor,
            title: LocalizationConstants.Settings.Badge.cardIssuing
        )
        let blockchainDomainsPresenter = BlockchainDomainsCommonCellPresenter(provider: blockchainDomainsAdapter)

        let items: [SettingsCellViewModel] = [
            .init(cellType: .badge(.limits, limitsPresenter)),
            .init(cellType: .clipboard(.walletID)),
            .init(cellType: .badge(.emailVerification, emailVerificationPresenter)),
            .init(cellType: .badge(.mobileVerification, mobileVerificationPresenter)),
            .init(cellType: .common(.blockchainDomains, blockchainDomainsPresenter)),
            .init(cellType: .common(.webLogin))
        ]

        var viewModel = SettingsSectionViewModel(
            sectionType: sectionType,
            items: items
        )

        let cardIssuingCellModelDisplay = SettingsCellViewModel(
            cellType: .common(.cardIssuing)
        )
        let cardIssuingCellModelOrder = SettingsCellViewModel(
            cellType: .badge(.cardIssuing, cardIssuingPresenter)
        )

        self.state = cardIssuingAdapter
            .isEnabled()
            .flatMap { isEnabled -> AnyPublisher<SettingsSectionLoadingState, Never> in

                guard isEnabled else {
                    viewModel.items = items
                    return .just(.loaded(next: .some(viewModel)))
                }

                return cardIssuingAdapter
                    .hasCard()
                    .map { hasCard -> SettingsSectionLoadingState in
                        switch hasCard {
                        case true:
                            viewModel.items = items + [cardIssuingCellModelDisplay]
                        case false:
                            viewModel.items = items + [cardIssuingCellModelOrder]
                        }

                        return .loaded(next: .some(viewModel))
                    }
                    .eraseToAnyPublisher()
            }
            .asObservable()
    }
}
