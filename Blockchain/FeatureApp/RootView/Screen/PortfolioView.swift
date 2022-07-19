//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureAppDomain
import FeatureAppUI
import FeatureDashboardUI
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

struct PortfolioView: UIViewControllerRepresentable {

    let store: Store<Void, RootViewAction>

    init(store: Store<Void, RootViewAction>) {
        self.store = store
    }

    private var onboardingViewsFactory = OnboardingViewsFactory()
    private var userAdapter: UserAdapterAPI = resolve()

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let provider = PortfolioViewControllerProvider()
        let viewController = provider.create(
            userHasCompletedOnboarding: userAdapter
                .onboardingUserState
                .map { $0.kycStatus == .verified && $0.hasEverPurchasedCrypto }
                .eraseToAnyPublisher(),
            onboardingChecklistViewBuilder: { [onboardingViewsFactory] in
                onboardingViewsFactory.makeOnboardingChecklistOverview()
            },
            drawerRouter: NoDrawer()
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
