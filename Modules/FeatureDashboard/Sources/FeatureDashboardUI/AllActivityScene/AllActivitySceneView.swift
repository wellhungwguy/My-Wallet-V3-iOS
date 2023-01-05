// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Foundation
import Localization
import SwiftUI
import UnifiedActivityUI

public struct AllActivitySceneView: View {
    let store: StoreOf<AllActivityScene>

    public init(store: StoreOf<AllActivityScene>) {
        self.store = store
    }

    public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
        VStack {
            searchBarSection
            allAssetsSection
        }
        .background(Color.WalletSemantic.light)
        .task {
            await viewStore.send(.onAppear).finish()
        }
        .primaryNavigation(
            title: LocalizationConstants.SuperApp.AllActivity.title,
            trailing: {
            IconButton(icon: .closev2.circle()) {
                viewStore.send(.onCloseTapped)
            }
            .frame(width: 24.pt, height: 24.pt)
        }
        )
    }
    }

    private var searchBarSection: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in

            SearchBar(
                text: viewStore.binding(\.$searchText),
                isFirstResponder: viewStore.binding(\.$isSearching),
                cancelButtonText: LocalizationConstants.SuperApp.AllActivity.cancelButton,
                placeholder: LocalizationConstants.SuperApp.AllActivity.searchPlaceholder
            )
            .frame(height: 48)
            .padding(.horizontal, Spacing.padding2)
            .padding(.vertical, Spacing.padding3)
        }
    }

    private var allAssetsSection: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let searchResults = viewStore.searchResults {
                        ForEach(searchResults) { searchResult in
                            ActivityRow(activityEntry: searchResult)

                            if searchResult.id != viewStore.searchResults?.last?.id {
                                Divider()
                                    .foregroundColor(.WalletSemantic.light)
                            }
                        }
                    }
                }
                .cornerRadius(16, corners: .allCorners)
                .padding(.horizontal, Spacing.padding2)
            }
        }
    }
}
