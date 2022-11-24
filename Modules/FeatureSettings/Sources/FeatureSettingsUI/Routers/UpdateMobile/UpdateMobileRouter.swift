// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class UpdateMobileRouter {

    private var stateService: UpdateMobileStateServiceAPI!
    private let serviceProvider: MobileSettingsServiceAPI
    private let navigationRouter: NavigationRouterAPI
    private let disposeBag = DisposeBag()

    init(
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        service: MobileSettingsServiceAPI = resolve()
    ) {
        self.serviceProvider = service
        self.navigationRouter = navigationRouter
    }

    func start() {
        stateService = UpdateMobileRouterStateService()
        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }

    func next(to state: UpdateMobileRouterStateService.State) {
        switch state {
        case .start:
            break
        case .end:
            navigationRouter.navigationControllerAPI?.popToRootViewControllerAnimated(animated: true)
        case .mobileNumber:
            showUpdateMobileScreen()
        case .codeEntry:
            showCodeEntryScreen()
        }
    }

    func previous() {
        navigationRouter.dismiss()
    }

    // MARK: - Private Functions

    func showUpdateMobileScreen() {
        let presenter = UpdateMobileScreenPresenter(stateService: stateService, settingsAPI: serviceProvider)
        let controller = UpdateMobileScreenViewController(presenter: presenter)
        navigationRouter.present(viewController: controller)
    }

    func showCodeEntryScreen() {
        let presenter = MobileCodeEntryScreenPresenter(stateService: stateService, service: serviceProvider)
        let controller = MobileCodeEntryViewController(presenter: presenter)
        navigationRouter.present(viewController: controller)
    }
}
