// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

@available(iOS 15.0, *)
struct MultiAppHeaderView: View {
    @Environment(\.refresh) var refreshAction: RefreshAction?

    @Binding var totalBalance: String
    @Binding var currentSelection: AppMode
    @Binding var contentOffset: ModalSheetContext
    @Binding var scrollOffset: CGPoint
    @Binding var isRefreshing: Bool

    @StateObject private var contentFrame = ViewFrame()
    private var thresholdOffsetForRefreshTrigger: CGFloat = Spacing.padding4 * 2.0

    init(
        totalBalance: Binding<String>,
        currentSelection: Binding<AppMode>,
        contentOffset: Binding<ModalSheetContext>,
        scrollOffset: Binding<CGPoint>,
        isRefreshing: Binding<Bool>
    ) {
        self._totalBalance = totalBalance
        self._currentSelection = currentSelection
        self._contentOffset = contentOffset
        self._scrollOffset = scrollOffset
        self._isRefreshing = isRefreshing
    }

    var body: some View {
        ZStack(alignment: .top) {
            ProgressView()
                .offset(y: calculateOffset())
                .zIndex(1)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .opacity(isRefreshing ? 1.0 : opacityForRefreshIndicator(percentageOffset: 1.0))
            VStack {
                VStack(spacing: Spacing.padding2) {
                    TotalBalanceView(balance: .constant(totalBalance))
                        .opacity(isRefreshing ? 0.0 : opacityForBalance(percentageOffset: 1.5))
                    MultiAppSwitcherView(currentSelection: $currentSelection)
                }
                .frameGetter($contentFrame.frame)
                .offset(y: calculateOffset())
                .animation(.interactiveSpring(), value: contentOffset)
                if interactiveExperienceAvailable() {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.clear
                .animatableLinearGradient(
                    fromColors: AppMode.trading.backgroundGradient,
                    toColors: AppMode.pkw.backgroundGradient,
                    startPoint: .leading,
                    endPoint: .trailing,
                    percent: currentSelection.isTrading ? 0 : 1
                )
                .ignoresSafeArea()
        )
    }

    // MARK: Private Helpers

    private func opacity(percentageOffset: CGFloat) -> CGFloat {
        contentOffset.progress * percentageOffset
    }

    private func reverseOpacity(percentageOffset: CGFloat) -> CGFloat {
        abs(reverseProgress() * percentageOffset)
    }

    private func opacityForRefreshIndicator(percentageOffset: CGFloat) -> CGFloat {
        guard interactiveExperienceAvailable() else {
            return fallbackToScrollOffset()
        }
        if contentOffset.progress < 1.0 {
            return 0.0
        }
        return reverseOpacity(percentageOffset: percentageOffset)
    }

    private func fallbackToScrollOffset() -> CGFloat {
        if scrollOffset.y < 0.0 {
            let heightAdjusted = contentFrame.frame.height + thresholdOffsetForRefreshTrigger
            let adjustedOffset = abs(scrollOffset.y) / heightAdjusted
            if let refreshAction  {
                if adjustedOffset > 1.1 {
                    Task {
                        isRefreshing = true
                        await refreshAction()
                        withAnimation {
                            isRefreshing = false
                        }
                    }
                }
            }
            return adjustedOffset
        }
        return 0.0
    }

    private func opacityForBalance(percentageOffset: CGFloat) -> CGFloat {
        guard interactiveExperienceAvailable() else {
            return 1.0 - fallbackToScrollOffset()
        }
        if contentOffset.progress > 1.1 {
            return 1.0 - reverseOpacity(percentageOffset: percentageOffset)
        }
        return opacity(percentageOffset: percentageOffset)
    }

    private func reverseProgress() -> CGFloat {
        abs(1.0 - contentOffset.progress)
    }

    private func calculateOffset() -> CGFloat {
        let adjustedHeight = contentFrame.frame.height + Spacing.padding2
        if contentOffset.offset.y > adjustedHeight {
            if let refreshAction {
                let thresholdForRefresh = adjustedHeight + thresholdOffsetForRefreshTrigger
                if contentOffset.offset.y > thresholdForRefresh, !isRefreshing {
                    Task {
                        isRefreshing = true
                        await refreshAction()
                        withAnimation {
                            isRefreshing = false
                        }
                    }
                }
            }
            return contentOffset.offset.y - adjustedHeight
        }
        return 0.0
    }
}

@available(iOS 15.0, *)
struct MultiappHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MultiAppHeaderView(
                totalBalance: .constant("$278,031.12"),
                currentSelection: .constant(.trading),
                contentOffset: .constant(ModalSheetContext(progress: 1.0, offset: .zero)),
                scrollOffset: .constant(.zero),
                isRefreshing: .constant(false)
            )
            .previewDisplayName("Trading Selected")

            MultiAppHeaderView(
                totalBalance: .constant("$278,031.12"),
                currentSelection: .constant(.pkw),
                contentOffset: .constant(ModalSheetContext(progress: 1.0, offset: .zero)),
                scrollOffset: .constant(.zero),
                isRefreshing: .constant(false)
            )
            .previewDisplayName("DeFi Selected")

            MultiAppHeaderView(
                totalBalance: .constant("$278,031.12"),
                currentSelection: .constant(.pkw),
                contentOffset: .constant(ModalSheetContext(progress: 1.0, offset: .zero)),
                scrollOffset: .constant(.zero),
                isRefreshing: .constant(true)
            )
            .previewDisplayName("Pull to refresh")
        }
    }
}
