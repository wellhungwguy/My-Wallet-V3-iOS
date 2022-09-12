// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

public final class WebLoginScreenPresenter {

    // MARK: - Types

    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.WebLogin
    private typealias LocalizedString = LocalizationConstants.Settings.WebLogin

    // MARK: - Public Properties

    let leadingButton: Screen.Style.LeadingButton = .back

    var titleView: Screen.Style.TitleView {
        .text(value: LocalizedString.title)
    }

    var barStyle: Screen.Style.Bar {
        .darkContent()
    }

    var qrCodeImage: Single<UIImage?> {
        service
            .qrCode
            .map { QRCode(string: $0) }
            .map { $0?.image }
            .catch { [weak self] _ in
                guard let alertPresenter = self?.alertPresenter else { return .just(nil) }
                alertPresenter.notify(
                    content: .init(
                        title: LocalizedString.ErrorAlert.title,
                        message: LocalizedString.ErrorAlert.message
                    )
                )
                return .just(nil)
            }
    }

    var qrCodeVisibility: Driver<Visibility> {
        qrCodeVisibilityRelay.asDriver()
    }

    let instructionViewModels: [InstructionCellViewModel] = {
        let inputs: [[InteractableTextViewModel.Input]] = [
            [.text(string: LocalizedString.Instruction.one)],
            [.text(string: LocalizedString.Instruction.two)],
            [.text(string: LocalizedString.Instruction.three)]
        ]
        return inputs.enumerated().map {
            InstructionCellViewModel(number: $0.offset + 1, inputs: $0.element)
        }
    }()

    let noticeViewModel: NoticeViewModel
    let actionButtonModel: ButtonViewModel

    // MARK: - Private Properties

    private let qrCodeVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let alertPresenter: AlertViewPresenterAPI
    private let service: WebLoginQRCodeServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Init

    public init(
        alertPresenter: AlertViewPresenterAPI = resolve(),
        service: WebLoginQRCodeServiceAPI = WebLoginQRCodeService()
    ) {
        self.alertPresenter = alertPresenter
        self.service = service

        let noticeLabel = LabelContent(
            text: LocalizedString.notice,
            font: .main(.semibold, 14),
            color: .destructiveButton,
            accessibility: .id(AccessibilityIDs.notice)
        )
        noticeViewModel = NoticeViewModel(
            imageViewContent: .init(imageResource: .local(name: "icon-alert", bundle: .featureSettingsUI)),
            imageViewSize: .edge(40),
            labelContents: noticeLabel,
            verticalAlignment: .center
        )

        actionButtonModel = .primary(with: LocalizedString.hideQRCode, accessibilityId: AccessibilityIDs.showQRCodeButton)

        qrCodeVisibilityRelay
            .asDriver()
            .map { $0 == .visible ? LocalizedString.hideQRCode : LocalizedString.showQRCode }
            .drive(actionButtonModel.textRelay)
            .disposed(by: disposeBag)

        actionButtonModel
            .tapRelay
            .withLatestFrom(qrCodeVisibilityRelay)
            .map(\.inverted)
            .bindAndCatch(to: qrCodeVisibilityRelay)
            .disposed(by: disposeBag)
    }
}
