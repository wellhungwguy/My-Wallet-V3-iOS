// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class BiometrySwitchViewPresenter: SwitchViewPresenting {

    // MARK: - Types

    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView
    private typealias AnalyticsEvent = AnalyticsEvents.Settings

    // MARK: - Public

    let viewModel: SwitchViewModel = .primary(accessibilityId: AccessibilityID.BioSwitchView)

    // MARK: - Proviate

    private let alertPresenter: AlertViewPresenterAPI
    private let interactor: BiometrySwitchViewInteractor
    private let disposeBag = DisposeBag()

    init(
        provider: BiometryProviding,
        settingsAuthenticating: AppSettingsAuthenticating,
        authenticationCoordinator: AuthenticationCoordinating,
        alertPresenter: AlertViewPresenterAPI = DIKit.resolve(),
        analyticsRecording: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.alertPresenter = alertPresenter
        interactor = BiometrySwitchViewInteractor(
            provider: provider,
            authenticationCoordinator: authenticationCoordinator,
            settingsAuthenticating: settingsAuthenticating
        )

        let isSwitchedOn = viewModel.isSwitchedOnRelay
            .asObservable()
            .share(replay: 1, scope: .whileConnected)

        Observable.combineLatest(
            isSwitchedOn,
            Observable.just(interactor.configurationStatus),
            Observable.just(interactor.supportedBiometryType)
        )
        .flatMap(weak: self) { (self, values) -> Observable<Bool> in
            self.toggleBiometry(values.2, biometryStatus: values.1, isOn: values.0)
        }
        .do(onNext: { [analyticsRecording] isEnabled in
            analyticsRecording.record(event: AnalyticsEvents.New.Security.biometricsUpdated(isEnabled: isEnabled))
        })
        .bindAndCatch(to: interactor.switchTriggerRelay)
        .disposed(by: disposeBag)

        isSwitchedOn
            .bind { analyticsRecording.record(event: AnalyticsEvent.settingsBiometryAuthSwitch(value: $0)) }
            .disposed(by: disposeBag)

        interactor
            .state
            .compactMap(\.value)
            .map(\.isEnabled)
            .bindAndCatch(to: viewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        interactor
            .state
            .compactMap(\.value)
            .map(\.isOn)
            .bindAndCatch(to: viewModel.isOnRelay)
            .disposed(by: disposeBag)
    }

    func toggleBiometry(_ biometryType: Biometry.BiometryType, biometryStatus: Biometry.Status, isOn: Bool) -> Observable<Bool> {
        Observable.create { [alertPresenter] observable -> Disposable in
            guard isOn else {
                observable.onNext(false)
                return Disposables.create()
            }

            if case .unconfigurable(let error) = biometryStatus {
                let accept = UIAlertAction(
                    title: LocalizationConstants.okString,
                    style: .cancel,
                    handler: { _ in
                        observable.onNext(false)
                    }
                )
                let content = AlertViewContent(
                    title: LocalizationConstants.Errors.error,
                    message: String(describing: error),
                    actions: [accept]
                )
                alertPresenter.notify(content: content, in: nil)
                return Disposables.create()
            }

            let name = biometryType.localizedName ?? ""
            let biometryWarning = String(format: LocalizationConstants.Biometry.biometryWarning, name)
            let cancel = UIAlertAction(
                title: LocalizationConstants.cancel,
                style: .cancel,
                handler: { _ in
                    observable.onNext(false)
                }
            )
            let accept = UIAlertAction(
                title: LocalizationConstants.continueString,
                style: .default,
                handler: { _ in
                    observable.onNext(true)
                }
            )
            let content = AlertViewContent(
                title: name,
                message: biometryWarning,
                actions: [cancel, accept]
            )
            alertPresenter.notify(content: content, in: nil)
            return Disposables.create()
        }
    }
}
