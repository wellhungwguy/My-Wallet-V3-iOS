// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class BackupFundsScreenPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias AccessibilityId = Accessibility.Identifier.Backup.IntroScreen
    private typealias LocalizedString = LocalizationConstants.BackupFundsScreen

    // MARK: - Properties

    var buttons: [ButtonViewModel] {
        contentReducer.buttons
    }

    var cells: [DetailsScreen.CellType] {
        contentReducer.cells
    }

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(
        value: .text(value: LocalizationConstants.BackupFundsScreen.title)
    )

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance {
        .custom(
            leading: leadingButton,
            trailing: trailingButton,
            barStyle: .darkContent()
        )
    }

    var navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction {
        .custom { [weak self] in
            self?.stateService.previousRelay.accept(())
        }
    }

    var navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction {
        switch entry {
        case .defiIntroScreen:
            return .custom { [weak self] in
                self?.stateService.previousRelay.accept(())
            }
        default:
            return .default
        }
    }

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private var trailingButton: Screen.Style.TrailingButton {
        switch entry {
        case .settings:
            return .none
        case .custody:
            return .close
        case .defiIntroScreen:
            return .skip
        }
    }

    private var leadingButton: Screen.Style.LeadingButton {
        switch entry {
        case .settings:
            return .back
        case .custody:
            return .none
        case .defiIntroScreen:
            return .none
        }
    }

    private let contentReducer: ContentReducer
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()
    private let entry: BackupRouterEntry
    private unowned let stateService: BackupRouterStateServiceAPI

    // MARK: - Init

    init(
        stateService: BackupRouterStateServiceAPI,
        entry: BackupRouterEntry,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.stateService = stateService
        self.entry = entry
        contentReducer = ContentReducer()

        contentReducer.startTapRelay
            .bindAndCatch(weak: self) { (self) in
                if entry == .custody {
                    self.analyticsRecorder.record(event: AnalyticsEvent.sbBackupWalletCardClicked)
                }

                self.stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
    }

    func viewDidLoad() {
        guard entry == .custody else { return }
        analyticsRecorder.record(event: AnalyticsEvent.sbBackupWalletCardShown)
    }
}

extension BackupFundsScreenPresenter {
    final class ContentReducer {

        // MARK: - Properties

        var startTapRelay: PublishRelay<Void> {
            startBackupButton.tapRelay
        }

        let cells: [DetailsScreen.CellType]
        let buttons: [ButtonViewModel]

        // MARK: - Private Properties

        private let startBackupButton: ButtonViewModel

        // MARK: - Init

        init() {
            startBackupButton = .primary(with: LocalizedString.action, accessibilityId: AccessibilityId.nextButton)
            let bodyText = """
            \(LocalizedString.Body.partA)

            \(LocalizedString.Body.List.title)
            \(LocalizedString.Body.List.item1)
            \(LocalizedString.Body.List.item2)
            \(LocalizedString.Body.List.item3)
            """
            let body = DefaultLabelContentPresenter(
                knownValue: bodyText,
                descriptors: .init(fontWeight: .medium, contentColor: .descriptionText, fontSize: 14, accessibility: .id(AccessibilityId.body))
            )
            let bodyWarning = DefaultLabelContentPresenter(
                knownValue: LocalizedString.Body.partB,
                descriptors: .init(fontWeight: .semibold, contentColor: .textFieldText, fontSize: 14, accessibility: .id(AccessibilityId.bodyWarning))
            )

            let noticeLabel = LabelContent(
                text: LocalizedString.Body.notice,
                font: .main(.semibold, 14),
                color: .destructiveButton,
                accessibility: .id(AccessibilityId.notice)
            )
            let notice = NoticeViewModel(
                imageViewContent: .init(imageResource: .local(name: "icon-alert", bundle: .featureSettingsUI)),
                imageViewSize: .edge(40),
                labelContents: noticeLabel,
                verticalAlignment: .center
            )

            cells = [
                .label(body),
                .label(bodyWarning),
                .notice(notice)
            ]
            buttons = [startBackupButton]
        }
    }
}
