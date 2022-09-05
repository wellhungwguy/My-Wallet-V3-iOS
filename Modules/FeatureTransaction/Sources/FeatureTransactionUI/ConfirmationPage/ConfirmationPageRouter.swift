// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RIBs

protocol ConfirmationPageRouting: AnyObject {
    func showWebViewWithTitledLink(_ titledLink: TitledLink)
}

final class ConfirmationPageRouter: ViewableRouter<Interactable, ViewControllable>, ConfirmationPageRouting {

    private let webViewRouter: WebViewRouterAPI

    init(
        interactor: ConfirmationPageInteractable,
        viewController: ViewControllable,
        webViewRouter: WebViewRouterAPI = resolve()
    ) {
        self.webViewRouter = webViewRouter
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func showWebViewWithTitledLink(_ titledLink: TitledLink) {
        webViewRouter.launchRelay.accept(titledLink)
    }
}
