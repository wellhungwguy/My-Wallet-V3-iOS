// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

@available(iOS 15, *)
struct StaticMultiAppContent: View {
    /// The current total balance
    @Binding var totalBalance: String
    /// The current selected app mode
    @Binding var currentModeSelection: AppMode
    /// The content offset for the modal sheet
    @Binding var contentOffset: ModalSheetContext
    /// The scroll offset for the inner scroll view, not currently used...
    @Binding var scrollOffset: CGPoint
    /// `True` when a pull to refresh is triggered, otherwise `false`
    @Binding var isRefreshing: Bool

    var body: some View {
        VStack(spacing: Spacing.padding1) {
            MultiAppHeaderView(
                totalBalance: $totalBalance,
                currentSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                scrollOffset: $scrollOffset,
                isRefreshing: $isRefreshing
            )
            .refreshable {
                await tempAsyncDelayMethod()
            }
            StaticMultiAppContentView(
                scrollOffset: $scrollOffset,
                content: {
                    ZStack {
                        MultiAppTradingView()
                            .opacity(currentModeSelection.isTrading ? 1.0 : 0.0)
                        MultiAppDefiView()
                            .opacity(currentModeSelection.isDefi ? 1.0 : 0.0)
                    }
                }
            )
            .frame(maxWidth: .infinity)
            .background(
                Color.semantic.light
                    .ignoresSafeArea(edges: .bottom)
            )
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
        }
        .background(
            Color.clear
                .animatableLinearGradient(
                    fromColors: AppMode.trading.backgroundGradient,
                    toColors: AppMode.pkw.backgroundGradient,
                    startPoint: .leading,
                    endPoint: .trailing,
                    percent: currentModeSelection.isTrading ? 0 : 1
                )
                .ignoresSafeArea()
        )
    }
}
