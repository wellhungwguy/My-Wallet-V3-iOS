// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class CloudBackupSwitchViewPresenter: SwitchViewPresenting {

    // MARK: - Types

    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView
    private typealias AnalyticsEvent = AnalyticsEvents.Settings

    // MARK: - Public

    private(set) lazy var viewModel: SwitchViewModel = {
        let viewModel: SwitchViewModel = .primary(accessibilityId: AccessibilityID.cloudBackup)
        viewModel.isSwitchedOnRelay
            .bindAndCatch(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)

        viewModel.isSwitchedOnRelay
            .bindAndCatch(weak: self) { (self, value) in
                self.analyticsRecording.record(event: AnalyticsEvent.settingsCloudBackupSwitch(value: value))
            }
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
        return viewModel
    }()

    // MARK: - Private

    private let interactor: SwitchViewInteracting
    private let analyticsRecording: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()

    init(
        cloudSettings: CloudBackupConfiguring,
        credentialsStore: CredentialsStoreAPI,
        analyticsRecording: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.analyticsRecording = analyticsRecording
        interactor = CloudBackupSwitchViewInteractor(
            cloudSettings: cloudSettings,
            credentialsStore: credentialsStore
        )
    }
}
