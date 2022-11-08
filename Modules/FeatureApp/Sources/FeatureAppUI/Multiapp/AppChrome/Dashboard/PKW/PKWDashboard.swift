// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import FeatureDashboardUI
import Foundation
import SwiftUI

public struct PKWDashboard: ReducerProtocol {
    let app: AppProtocol
    let allCryptoAssetService: AllCryptoAssetsServiceAPI

    public enum Route: NavigationRoute {
        case showAllAssets

        public func destination(in store: Store<State, Action>) -> some View {
            switch self {

            case .showAllAssets:
                return AllAssetsView(store: store.scope(state: \.allAssetsState, action: Action.allAssetsAction))
            }
        }
    }

    public enum Action: Equatable, NavigationAction {
        case route(RouteIntent<Route>?)
        case assetsAction(DashboardAssetsSection.Action)
        case allAssetsAction(FeatureAllAssets.Action)
    }

    public struct State: Equatable, NavigationState {
        public var title: String
        public var assetsState: DashboardAssetsSection.State = .init(presentedAssetsType: .nonCustodial)
        public var allAssetsState: FeatureAllAssets.State = .init(with: .nonCustodial)
        public var route: RouteIntent<Route>?

        public init(title: String) {
            self.title = title
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.assetsState, action: /Action.assetsAction) {
                DashboardAssetsSection(
                    allCryptoAssetService: allCryptoAssetService,
                    app: app
                )
        }

        Scope(state: \.allAssetsState, action: /Action.allAssetsAction) {
            FeatureAllAssets(
                allCryptoService: allCryptoAssetService,
                app: app
            )
        }

        Reduce { state, action in
            switch action {
            case .route(let routeIntent):
                state.route = routeIntent
                return .none
            case .allAssetsAction:
                return .none
            case .assetsAction(let action):
                switch action {
                case .onAllAssetsTapped:
                    state.route = .navigate(to: .showAllAssets)
                    return .none
                default:
                    return .none
                }
            }
        }
    }
}
