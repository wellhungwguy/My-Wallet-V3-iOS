//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureCoinDomain
import FeatureCoinUI
import FeatureDashboardUI
import PlatformUIKit
import SwiftUI
import ToolKit

public struct PricesView: UIViewControllerRepresentable {

    public init() {}

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    public func makeUIViewController(context: Context) -> some UIViewController {
        let provider = PricesViewControllerProvider()
        let viewController = provider.create(
            drawerRouter: NoDrawer(),
            showSupportedPairsOnly: false
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}

public class NoDrawer: DrawerRouting {
    public func toggleSideMenu() {}
    public func closeSideMenu() {}

    public init() {}
}
