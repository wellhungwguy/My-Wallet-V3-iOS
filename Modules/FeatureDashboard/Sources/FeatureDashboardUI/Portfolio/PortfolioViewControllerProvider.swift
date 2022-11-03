// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformUIKit
import SwiftUI

public final class PortfolioViewControllerProvider {
    public init() {}
    public func create(
        userHasCompletedOnboarding: AnyPublisher<Bool, Never>,
        @ViewBuilder onboardingChecklistViewBuilder: @escaping () -> some View,
        drawerRouter: DrawerRouting
    ) -> BaseScreenViewController {
        PortfolioViewController(
            userHasCompletedOnboarding: userHasCompletedOnboarding,
            onboardingChecklistViewBuilder: onboardingChecklistViewBuilder,
            presenter: PortfolioScreenPresenter(
                drawerRouter: drawerRouter
            )
        )
    }
}
