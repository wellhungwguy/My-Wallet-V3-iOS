// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import SwiftUI

public protocol BackupFundsRouterAPI {
    var completionRelay: PublishRelay<Void> { get }
    var completionSubject: PassthroughSubject<Void, Never> { get }
    var skipSubject: PassthroughSubject<Void, Never> { get }
    func start()
}

public final class BackupFundsRouter: BackupFundsRouterAPI {

    // MARK: - BackupRouterAPI

    public let completionRelay = PublishRelay<Void>()
    public let completionSubject = PassthroughSubject<Void, Never>()
    public let skipSubject = PassthroughSubject<Void, Never>()
    private var stateService: BackupRouterStateService!
    private let navigationRouter: NavigationRouterAPI
    private let recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI
    private let disposeBag = DisposeBag()
    private let entry: BackupRouterEntry

    public init(
        entry: BackupRouterEntry,
        navigationRouter: NavigationRouterAPI,
        recoveryPhraseVerifying: RecoveryPhraseVerifyingServiceAPI = resolve()
    ) {
        self.entry = entry
        self.navigationRouter = navigationRouter
        recoveryPhraseVerifyingService = recoveryPhraseVerifying
    }

    public func start() {
        stateService = BackupRouterStateService(entry: entry)
        stateService
            .action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                case .skip:
                    self.skip()
                case .dismiss:
                    self.dismiss()
                case .complete:
                    self.complete()
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }

    private func complete() {
        switch entry {
        case .settings:
            navigationRouter.navigationControllerAPI?.popToRootViewControllerAnimated(animated: true)
            completionRelay.accept(())
            completionSubject.send(())

        case .defiIntroScreen:
            navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                self.completionRelay.accept(())
                self.completionSubject.send(())
            })
        case .custody:
            navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                self.completionRelay.accept(())
                self.completionSubject.send(())
            })
        }
    }

    private func dismiss() {
        switch entry {
        case .settings:
            navigationRouter.navigationControllerAPI?.popToRootViewControllerAnimated(animated: true)
        case .custody:
            navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
        case .defiIntroScreen:
            navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
        }
    }

    private func skip() {
        navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.skipSubject.send(())
        })
    }

    func next(to state: BackupRouterStateService.State) {
        switch state {
        case .start, .end:
            break
        case .backupFunds(let presentationType, let entry):
            showBackupFunds(presentationType: presentationType, entry: entry)
        case .recovery:
            let presenter = RecoveryPhraseScreenPresenter(
                stateService: stateService,
                recoveryPhraseVerifying: recoveryPhraseVerifyingService
            )
            let controller = RecoveryPhraseViewController(presenter: presenter)
            navigationRouter.navigationControllerAPI?.pushViewController(controller, animated: true)
        case .verification:
            let presenter = VerifyBackupScreenPresenter(
                stateService: stateService,
                service: recoveryPhraseVerifyingService
            )
            let controller = VerifyBackupViewController(presenter: presenter)
            navigationRouter.navigationControllerAPI?.pushViewController(controller, animated: true)
        case .skipped:
            skip()
        }
    }

    func previous() {
        navigationRouter.dismiss()
    }

    // MARK: - Private Functions

    private func showBackupFunds(presentationType: PresentationType, entry: BackupRouterEntry) {
        let presenter = BackupFundsScreenPresenter(stateService: stateService, entry: entry)
        let controller = DetailsScreenViewController(presenter: presenter)
        controller.isModalInPresentation = true
        navigationRouter.present(viewController: controller, using: presentationType)
    }
}
