// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

extension UIWindow {

    /// Ensure code is running on main thread and sets the rootViewController
    func setRootViewController(_ viewController: UIViewController) {
        ensureIsOnMainQueue()
        rootViewController = viewController
    }
}
