//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import FeatureActivityUI
import SwiftUI

public struct ActivityView: UIViewControllerRepresentable {

    public init() {}

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    public func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = ActivityScreenViewController(drawerRouting: NoDrawer())
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
