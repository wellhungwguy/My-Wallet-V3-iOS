// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import DIKit
import FeatureDashboardUI
import SwiftUI

struct PKWDashboardView: View {
    let store: StoreOf<PKWDashboard>

    init(store: StoreOf<PKWDashboard>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
//            PrimaryNavigationView {
                ScrollView {
                    VStack(spacing: 32) {
                        DashboardAssetSectionView(store: self.store.scope(
                            state: \.assetsState,
                            action: PKWDashboard.Action.assetsAction
                        ))

                        DashboardActivitySectionView(
                            store: self.store.scope(state: \.activityState, action: PKWDashboard.Action.activityAction)
                        )
                    }
                    .navigationRoute(in: store)
                    .padding(.bottom, Spacing.padding6)
                    .navigationTitle(viewStore.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .frame(maxWidth: .infinity)
                }
                .background(Color.semantic.light.ignoresSafeArea(edges: .bottom))
        }
//        }
    }
}

// MARK: Provider

func provideDefiDashboard(
    tab: Tab,
    store: StoreOf<DashboardContent>
) -> some View {
    PKWDashboardView(
        store: store.scope(
            state: \.defiState.home,
            action: DashboardContent.Action.defiHome
        )
    )
    .tabItem {
        Label(
            title: {
                Text(tab.name.localized())
                    .typography(.micro)
            },
            icon: { tab.icon.image }
        )
    }
    .tag(tab.ref)
    .id(tab.ref.description)
    .accessibilityIdentifier(tab.ref.description)
}
