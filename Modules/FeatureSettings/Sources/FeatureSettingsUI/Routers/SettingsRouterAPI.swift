// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxRelay

public protocol SettingsRouterAPI: RoutingPreviousStateEmitterAPI {

    var actionRelay: PublishRelay<SettingsScreenAction> { get }
    var navigationRouter: NavigationRouterAPI { get }

    func makeViewController() -> BaseScreenViewController
}
