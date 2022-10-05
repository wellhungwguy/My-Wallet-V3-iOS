// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - PlatformUIKit Module

    public static var platformUIKit = module {

        // MARK: - AlertViewPresenterAPI

        single { AlertViewPresenter() as AlertViewPresenterAPI }

        // MARK: - LoadingViewPresenting

        single { LoadingViewPresenter() }

        factory { () -> LoadingViewPresenting in
            let presenter: LoadingViewPresenter = DIKit.resolve()
            return presenter
        }

        // MARK: - TopMostViewControllerProviding

        factory { UIApplication.shared as TopMostViewControllerProviding }

        // MARK: - WebViewServiceAPI

        factory { WebViewService() as WebViewServiceAPI }

        // MARK: - WebViewRouterAPI

        factory { WebViewRouter() as WebViewRouterAPI }

        // MARK: - Pasteboarding

        factory { UIPasteboard.general as Pasteboarding }

        // MARK: - Secure Channel

        single { SecureChannelRouter() as SecureChannelRouting }

        factory { SecureChannelNotificationRelay() as SecureChannelNotificationRelaying }
    }
}
