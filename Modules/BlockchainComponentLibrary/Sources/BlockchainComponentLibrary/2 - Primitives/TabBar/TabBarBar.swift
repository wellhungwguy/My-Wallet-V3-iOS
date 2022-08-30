// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A tab bar to display along the bottom of the screen.
/// Used by `TabBar`
struct TabBarBar: View {

    private let coordinateSpace = "TabBarBarCoordinateSpace"
    private let highlightBarSize = CGSize(width: 48, height: 1)

    @Binding private var activeTabIdentifier: AnyHashable
    private let highlightBarVisible: Bool
    private let items: [TabBarItem]

    /// Create a tab bar view with any number of items.
    /// - Parameter activeTabIdentifier: Binding for `identifier` from `items` for the currently selected tab.
    /// - Parameter highlightBarVisible: Whether or not to show the horizontal bar above the selected tab
    /// - Parameter items: Items supports many `.tab` elements, and a single `.fab` element.
    init(
        activeTabIdentifier: Binding<AnyHashable>,
        highlightBarVisible: Bool,
        items: [TabBarItem]
    ) {
        precondition(items.filter(\.isFab).count <= 1, "TabBarView currently only supports one FAB")
        _activeTabIdentifier = activeTabIdentifier
        self.highlightBarVisible = highlightBarVisible
        self.items = items
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                switch item {
                case .tab(identifier: let identifier, icon: let icon, title: let title):
                    TabBarButton(
                        isOn: Binding(
                            get: {
                                activeTabIdentifier == identifier
                            },
                            set: { _ in
                                activeTabIdentifier = identifier
                            }
                        ),
                        icon: icon,
                        title: title
                    )
                    .frame(maxWidth: .infinity)
                    .anchorPreference(key: AnchorFramesPreferenceKey.self, value: .bounds) {
                        [identifier: $0]
                    }
                case .fab(identifier: _, isActive: let isActive, isPulsing: let isPulsing):
                    FloatingActionButton(
                        isOn: isActive
                    )
                    .frame(maxWidth: .infinity)
                    .background(
                        Circle()
                            .fill(Color.semantic.background)
                            .padding(8)
                    )
                    .pulse(enabled: isPulsing, inset: 8)
                }
            }
        }
        .backgroundPreferenceValue(AnchorFramesPreferenceKey.self) { preferences in
            if highlightBarVisible {
                preferences[activeTabIdentifier].map { preference in
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(Color.semantic.primary)
                            .frame(width: highlightBarSize.width, height: highlightBarSize.height)
                            .offset(x: barOffset(in: proxy[preference]))
                            .animation(.interactiveSpring())
                    }
                }
            } else {
                EmptyView()
            }
        }
        .background(Color.semantic.background)
    }

    /// Center the highlight bar within the given rect
    /// - Parameter rect: CGRect from GeometryProxy to center within
    /// - Returns: X offset for highlight bar
    private func barOffset(in rect: CGRect) -> CGFloat {
        rect.minX + (
            (rect.width / 2) - (highlightBarSize.width / 2)
        )
    }
}

// MARK: - Preferences

private struct AnchorFramesPreferenceKey: PreferenceKey {
    static var defaultValue: [AnyHashable: Anchor<CGRect>] = [:]

    static func reduce(value: inout [AnyHashable: Anchor<CGRect>], nextValue: () -> [AnyHashable: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - Previews

struct TabBarBar_Previews: PreviewProvider {
    static var previews: some View {
        WalletPreviewContainer(
            activeTabIdentifier: "home",
            fabIsActive: false
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Wallet")

        ExchangePreviewContainer(
            activeTabIdentifier: "home"
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Exchange")
    }

    struct WalletPreviewContainer: View {
        @State var activeTabIdentifier: AnyHashable
        @State var fabIsActive: Bool

        var body: some View {
            TabBarBar(
                activeTabIdentifier: $activeTabIdentifier,
                highlightBarVisible: true,
                items: [
                    .tab(
                        identifier: "home",
                        icon: .home,
                        title: "Home"
                    ),
                    .tab(
                        identifier: "prices",
                        icon: .lineChartUp,
                        title: "Prices"
                    ),
                    .fab(
                        identifier: "floatingActionButtonIdentifier",
                        isActive: $fabIsActive,
                        isPulsing: true
                    ),
                    .tab(
                        identifier: "rewards",
                        icon: .interestCircle,
                        title: "Rewards"
                    ),
                    .tab(
                        identifier: "activity",
                        icon: .pending,
                        title: "Activity"
                    )
                ]
            )
        }
    }

    struct ExchangePreviewContainer: View {
        @State var activeTabIdentifier: AnyHashable

        var body: some View {
            TabBarBar(
                activeTabIdentifier: $activeTabIdentifier,
                highlightBarVisible: false,
                items: [
                    .tab(
                        identifier: "home",
                        icon: .home,
                        title: "Home"
                    ),
                    .tab(
                        identifier: "trade",
                        icon: .swap,
                        title: "Trade"
                    ),
                    .tab(
                        identifier: "portfolio",
                        icon: .portfolio,
                        title: "Portfolio"
                    ),
                    .tab(
                        identifier: "history",
                        icon: .pending,
                        title: "History"
                    ),
                    .tab(
                        identifier: "account",
                        icon: .user,
                        title: "Account"
                    )
                ]
            )
        }
    }
}
