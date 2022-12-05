// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureAuthenticationUI
import FeatureTourUI
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

public struct TourViewAdapter: View {

    @BlockchainApp var app

    private let store: Store<WelcomeState, WelcomeAction>
    private let featureFlagService: FeatureFlagsServiceAPI

    @State var newTourEnabled: Bool?
    @State var manualLoginEnabled: Bool = false

    public init(store: Store<WelcomeState, WelcomeAction>, featureFlagService: FeatureFlagsServiceAPI) {
        self.store = store
        self.featureFlagService = featureFlagService
    }

    public var body: some View {
        Group {
            switch newTourEnabled {
            case nil:
                LoadingStateView(title: "")
            case true?:
                WithViewStore(store) { viewStore in
                    OnboardingCarouselView(
                        environment: TourEnvironment(
                            createAccountAction: { viewStore.send(.navigate(to: .createWallet)) },
                            restoreAction: { viewStore.send(.navigate(to: .restoreWallet)) },
                            logInAction: { viewStore.send(.navigate(to: .emailLogin)) },
                            manualLoginAction: { viewStore.send(.navigate(to: .manualLogin)) }
                        ),
                        manualLoginEnabled: manualLoginEnabled
                    )
                }
                .navigationRoute(in: store)
            case false?:
                WelcomeView(store: store)
                    .primaryNavigation()
                    .navigationBarHidden(true)
            }
        }
        .onReceive(featureFlagService.isEnabled(.newOnboardingTour)) { isEnabled in
            newTourEnabled = isEnabled
        }
        .onReceive(
            app
                .publisher(for: blockchain.app.configuration.manual.login.is.enabled, as: Bool.self)
                .prefix(1)
                .replaceError(with: false)
        ) { isEnabled in
            manualLoginEnabled = isEnabled
        }
    }
}
