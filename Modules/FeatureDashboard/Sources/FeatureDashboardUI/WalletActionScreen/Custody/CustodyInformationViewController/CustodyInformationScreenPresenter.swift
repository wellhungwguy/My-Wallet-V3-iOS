// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class CustodyInformationScreenPresenter {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.CustodyInfo

    // MARK: - Navigation Properties

    var trailingButton: Screen.Style.TrailingButton {
        .content(
            .init(
                title: nil,
                image: UIImage(named: "cancel_icon", in: .main, with: nil),
                accessibility: .id(AccessibilityId.backButton)
            )
        )
    }

    var leadingButton: Screen.Style.LeadingButton {
        .none
    }

    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationID.title)
    }

    var barStyle: Screen.Style.Bar {
        .darkContent()
    }

    private typealias LocalizationID = LocalizationConstants.CustodyWalletInformation

    // MARK: - Properties

    var description: LabelContent {
        .init(
            text: LocalizationID.Description.partOne,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )
    }

    var subDescription: LabelContent {
        .init(
            text: LocalizationID.Description.partTwo,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id(AccessibilityId.subDescriptionLabel)
        )
    }

    let okButtonViewModel: ButtonViewModel

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private unowned let stateService: CustodyActionStateServiceAPI

    init(stateService: CustodyActionStateServiceAPI) {
        self.stateService = stateService

        self.okButtonViewModel = .primary(with: LocalizationConstants.okString, accessibilityId: AccessibilityId.okButton)
        sendAnalytics()
    }

    func navigationBarTrailingButtonTapped() {
        stateService.previousRelay.accept(())
    }

    private func sendAnalytics() {
        let analyticsService: SimpleBuyAnalayticsServicing = resolve()
        analyticsService.recordCustodyWalletCardShownEvent()
        analyticsService.bind(okButtonViewModel.tapRelay)

        okButtonViewModel.tapRelay
            .bindAndCatch(to: stateService.nextRelay)
            .disposed(by: disposeBag)
    }
}

extension Accessibility.Identifier {
    fileprivate enum CustodyInfo {
        private static let prefix = "CustodyInfoScreen."
        static let backButton = "\(prefix)backButton"
        static let descriptionLabel = "\(prefix)descriptionLabel"
        static let subDescriptionLabel = "\(prefix)subDescriptionLabel"
        static let okButton = "\(prefix)okButton"
    }
}
