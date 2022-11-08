// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import DIKit
import Foundation
import Localization
import SwiftUI

public struct DashboardActivitySectionView: View {
    @ObservedObject var viewStore: ViewStoreOf<DashboardActivitySection>
    let store: StoreOf<DashboardActivitySection>

    public init(store: StoreOf<DashboardActivitySection>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                sectionHeader
                    .padding(.vertical, Spacing.padding1)
                custodialAssetsSection
            }
            .task {
                await viewStore.send(.onAppear).finish()
            }
            .padding(.horizontal, Spacing.padding2)
        })
    }

    var custodialAssetsSection: some View {
        VStack(spacing: 0) {
//            if let activityItems = viewStore.activityItems {
//                ForEach(activityItems) { item in
//                    Text(item)
//                }
//            } else
//            {
//                Text("Loading")
//            }
        }
        .cornerRadius(16, corners: .allCorners)
    }

    var sectionHeader: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            HStack {
                Text("Activity")
                    .typography(.body2)
                    .foregroundColor(.semantic.body)
                Spacer()
                Button {
                    viewStore.send(.onAllActivityTapped)
                } label: {
                    Text(LocalizationConstants.MultiApp.Dashboard.seeAllLabel)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.primary)
                }
            }
        })
    }
}
