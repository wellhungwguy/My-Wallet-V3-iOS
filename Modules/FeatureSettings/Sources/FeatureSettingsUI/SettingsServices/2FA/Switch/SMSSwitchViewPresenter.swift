// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

class SMSSwitchViewPresenter: SwitchViewPresenting {

    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView

    let viewModel = SwitchViewModel.primary(accessibilityId: AccessibilityID.SMSSwitchView)

    private let interactor: SwitchViewInteracting
    private let disposeBag = DisposeBag()

    init(service: SMSTwoFactorSettingsServiceAPI & SettingsServiceAPI) {
        self.interactor = SMSSwitchViewInteractor(service: service)

        viewModel.isSwitchedOnRelay
            .bindAndCatch(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)

        interactor.state
            .compactMap(\.value)
            .map(\.isEnabled)
            .bindAndCatch(to: viewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        interactor.state
            .compactMap(\.value)
            .map(\.isOn)
            .bindAndCatch(to: viewModel.isOnRelay)
            .disposed(by: disposeBag)
    }
}
