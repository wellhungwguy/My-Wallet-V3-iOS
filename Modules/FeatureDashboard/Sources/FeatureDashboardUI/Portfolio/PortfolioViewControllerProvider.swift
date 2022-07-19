// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformUIKit
import SwiftUI

public final class PortfolioViewControllerProvider {
    public init() {}
    public func create<OnboardingChecklist: View>(
        userHasCompletedOnboarding: AnyPublisher<Bool, Never>,
        @ViewBuilder onboardingChecklistViewBuilder: @escaping () -> OnboardingChecklist,
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
