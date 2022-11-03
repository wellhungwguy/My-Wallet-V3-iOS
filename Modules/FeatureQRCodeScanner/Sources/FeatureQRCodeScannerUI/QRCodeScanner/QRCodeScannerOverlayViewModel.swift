// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureWalletConnectDomain
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

final class QRCodeScannerOverlayViewModel {

    /// The visibility of the camera roll button
    var cameraRollButtonVisibility: AnyPublisher<Visibility, Never> {
        cameraRollButtonVisibilityRelay.eraseToAnyPublisher()
    }

    /// The visibility of the connect dApps button
    var dAppsButtonVisibility: AnyPublisher<Visibility, Never> {
        dAppsButtonVisibilityRelay.eraseToAnyPublisher()
    }

    var titleLabelContent: AnyPublisher<LabelContent, Never> {
        titleLabelContentRelay.eraseToAnyPublisher()
    }

    var subtitleLabelContent: AnyPublisher<LabelContent, Never> {
        subtitleLabelContentRelay.eraseToAnyPublisher()
    }

    var dAppsButtonTitle: AnyPublisher<String, Never> {
        dAppsButtonTitleRelay.eraseToAnyPublisher()
    }

    /// Is the flash enabled
    var flashEnabled: AnyPublisher<Bool, Never> {
        qrCodeFlashService.isEnabled.eraseToAnyPublisher()
    }

    /// Streams events when a scan was successful
    let scanSuccess = PassthroughSubject<Result<Bool, Error>, Never>()

    /// Streams events when the flash button is tapped
    let flashTapRelay = PassthroughSubject<Void, Never>()

    /// Streams events when the camera button is tapped
    let cameraTapRelay = PassthroughSubject<Void, Never>()

    /// Closure for handling camera tap events
    var cameraButtonTapped: (() -> Void)?

    var connectedDAppsTapped: (() -> Void)?

    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let walletConnectSessionRepository: SessionRepositoryAPI
    private let qrCodeFlashService = QRCodeScannerFlashService()
    private let cameraRollButtonVisibilityRelay = CurrentValueSubject<Visibility, Never>(.hidden)
    private let dAppsButtonVisibilityRelay = CurrentValueSubject<Visibility, Never>(.hidden)
    private let dAppsButtonTitleRelay = CurrentValueSubject<String, Never>(
        String(format: LocalizationConstants.QRCodeScanner.connectedDapps, 0)
    )
    private let titleLabelContentRelay = CurrentValueSubject<LabelContent, Never>(.empty)
    private let subtitleLabelContentRelay = CurrentValueSubject<LabelContent, Never>(.empty)
    private var cancellables = [AnyCancellable]()

    init(
        supportsCameraRoll: Bool,
        titleText: String?,
        subtitleText: String? = nil,
        walletConnectSessionRepository: SessionRepositoryAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
        analyticsEventRecorder: AnalyticsEventRecorderAPI
    ) {
        self.analyticsEventRecorder = analyticsEventRecorder
        self.walletConnectSessionRepository = walletConnectSessionRepository
        cameraRollButtonVisibilityRelay.send(.init(boolValue: supportsCameraRoll))
        if let subtitleText {
            let labelContent = LabelContent(
                text: subtitleText,
                font: .main(.medium, 14),
                color: .white,
                alignment: .left
            )
            subtitleLabelContentRelay.send(labelContent)
        }
        if let titleText {
            let titleContent = LabelContent(
                text: titleText,
                font: .main(.semibold, 16),
                color: .white,
                alignment: .center
            )
            titleLabelContentRelay.send(titleContent)
        }
        flashTapRelay
            .sink { [weak self] _ in
                self?.toggleFlash()
            }
            .store(in: &cancellables)

        cameraTapRelay
            .sink { [weak self] in
                self?.cameraButtonTapped?()
            }
            .store(in: &cancellables)

        let walletConnectSessions = featureFlagsService
            .isEnabled(.walletConnectEnabled)
            .flatMap { [walletConnectSessionRepository] isEnabled -> AnyPublisher<Int, Never> in
                isEnabled ? walletConnectSessionRepository.retrieveConnectedApps()
                    : AnyPublisher<Int, Never>.just(0)
            }
            .map { connectedSessions -> (Visibility, String) in
                guard connectedSessions != 0 else {
                    return (.hidden, "")
                }
                let title: String
                if connectedSessions == 1 {
                    title = LocalizationConstants.QRCodeScanner.connectedDApp
                } else {
                    title = String(
                        format: LocalizationConstants.QRCodeScanner.connectedDapps,
                        String(connectedSessions)
                    )
                }
                return (.visible, title)
            }

        let reloadConnectedDApps = PassthroughSubject<Void, Never>()

        walletConnectSessions
            .sink { [weak self] visibility, title in
                self?.dAppsButtonVisibilityRelay.send(visibility)
                self?.dAppsButtonTitleRelay.send(title)
            }
            .store(in: &cancellables)

        reloadConnectedDApps
            .flatMap { walletConnectSessions }
            .sink { [weak self] visibility, title in
                self?.dAppsButtonVisibilityRelay.send(visibility)
                self?.dAppsButtonTitleRelay.send(title)
            }
            .store(in: &cancellables)

        connectedDAppsTapped = {
            analyticsEventRecorder.record(event: AnalyticsEvents
                .New
                .WalletConnect
                .connectedDappsListClicked(origin: .qrCode))
            let router: WalletConnectRouterAPI = resolve()
            router.showConnectedDApps {
                reloadConnectedDApps.send(())
            }
        }
    }

    private func toggleFlash() {
        qrCodeFlashService.toggleFlash()
    }
}
