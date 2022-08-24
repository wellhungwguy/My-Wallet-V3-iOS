// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import UIKit

extension DependencyContainer {

    // MARK: - UIKitExtensions Module

    public static var uiKitExtensions = module {
        factory { UIApplication.shared as TopMostViewControllerProviding }
    }
}
