// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A container view that displays a tab bar along the bottom of the screen, and switches the visible content view.
///
/// # Figma
///
/// [Navigation](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=209%3A1662)
public struct TabBar<Content: View>: View {

    @Binding private var activeTabIdentifier: AnyHashable
    private let highlightBarVisible: Bool
    private let content: () -> Content

    @State private var items: [TabBarItem] = []

    /// A view that switches between multiple child views using interactive user
    /// interface elements.
    ///
    /// To create a user interface with tabs, place views in a `TabBar` and apply
    /// the ``View/tabBarItem(_:)`` modifier to the contents of each tab. The
    /// following example creates a tab view with two tabs and a floating action button.
    ///
    /// `tabBarItem` can be specified inside the view itself, external here just for an example.
    ///
    ///     TabBar(activeTabIdentifier: $activeTabIdentifier) {
    ///         Text("The First Tab")
    ///             .tabBarItem(
    ///                 .tab(
    ///                     identifier: "first",
    ///                     icon: .home,
    ///                     title: "Home"
    ///                 )
    ///             )
    ///         EmptyView() // No content for FAB
    ///             .tabBarItem(
    ///                 .fab(
    ///                     identifier: "floatingActionButton",
    ///                     isActive: $fabIsActive,
    ///                     isPulsing: true
    ///                 )
    ///             )
    ///         Text("The Second Tab")
    ///             .tabBarItem(
    ///                 .tab(
    ///                     identifier: "second",
    ///                     icon: .lineChartUp,
    ///                     title: "Prices"
    ///                 )
    ///             )
    ///     }
    ///
    ///  An Environment variable is available for checking if a view is within the currently active tab.
    ///  This can be useful for pausing live reloading, triggering animations, etc.
    ///
    ///  `@Environment(\.isActiveTab) var isActiveTab: Bool`
    ///
    /// - Parameters:
    ///   - activeTabIdentifier: Binding for `identifier` from `items` for the currently selected tab.
    ///   - highlightBarVisible: Whether or not to show the horizontal bar above the selected tab
    ///   - content: View builder for content views displayed above the tab bar. Each view is conditionally displayed based on the active tab identifier.
    ///
    /// - Note:
    /// Only a single tabBarItem of type `.fab` is supported.
    public init(
        activeTabIdentifier: Binding<AnyHashable>,
        highlightBarVisible: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _activeTabIdentifier = activeTabIdentifier
        self.highlightBarVisible = highlightBarVisible
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environment(\.activeTab, activeTabIdentifier)
                    .onPreferenceChange(TabBarItemPreferenceKey.self) { item in
                        if let item, !items.contains(item) {
                            items.insert(item, at: 0)
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBarBar(
                activeTabIdentifier: $activeTabIdentifier,
                highlightBarVisible: highlightBarVisible,
                items: items
            )
        }
    }
}

// MARK: - Modifier, Preference, Environment

/// Internal modifier, use publically via `View.tabBarItem(...)`
struct TabBarItemModifier: ViewModifier {
    let item: TabBarItem

    @Environment(\.activeTab) var activeTabIdentifier: AnyHashable

    func body(content: Content) -> some View {
        Group {
            if activeTabIdentifier == item.id {
                content
                    .environment(\.isActiveTab, true)
            } else {
                content
                    .environment(\.isActiveTab, false)
                    .hidden()
            }
        }
        .preference(key: TabBarItemPreferenceKey.self, value: item)
    }
}

/// Preference key for passing the tab bar items up to the TabBar
struct TabBarItemPreferenceKey: PreferenceKey {
    static var defaultValue: TabBarItem?

    static func reduce(value: inout TabBarItem?, nextValue: () -> TabBarItem?) {
        value = nextValue()
    }
}

/// Environment key for passing the active tab idententifier down into the Tab Bar item's view
struct ActiveTabEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyHashable("")
}

/// Environment key for checking if the current view is the active tab.
struct IsActiveTabEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {

    /// Environment key for passing the active tab idententifier down into the Tab Bar item's view
    var activeTab: AnyHashable {
        get { self[ActiveTabEnvironmentKey.self] }
        set { self[ActiveTabEnvironmentKey.self] = newValue }
    }

    /// Environment key for checking if the current view is within the active tab.
    /// Useful for pausing animations / live reloading etc while not the active tab
    /// Or for performing animations when switching to a tab
    public var isActiveTab: Bool {
        get { self[IsActiveTabEnvironmentKey.self] }
        set { self[IsActiveTabEnvironmentKey.self] = newValue }
    }
}

// MARK: - Previews

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        WalletPreviewContainer(
            activeTabIdentifier: WalletPreviewContainer.Tab.home,
            fabIsActive: false
        )
        .previewLayout(.device)
        .previewDisplayName("Wallet")

        ExchangePreviewContainer(
            activeTabIdentifier: ExchangePreviewContainer.Tab.home
        )
        .previewLayout(.device)
        .previewDisplayName("Exchange")
    }

    struct WalletPreviewContainer: View {
        enum Tab: Hashable {
            case home
            case prices
            case rewards
            case activity
        }

        @State var activeTabIdentifier: AnyHashable
        @State var fabIsActive: Bool

        var body: some View {
            TabBar(
                activeTabIdentifier: $activeTabIdentifier,
                highlightBarVisible: true
            ) {
                Text("Home")
                    .tabBarItem(
                        .tab(
                            identifier: Tab.home,
                            icon: .home,
                            title: "Home"
                        )
                    )

                Text("Prices")
                    .tabBarItem(
                        .tab(
                            identifier: Tab.prices,
                            icon: .lineChartUp,
                            title: "Prices"
                        )
                    )

                Text("Foo")
                    .tabBarItem(
                        .fab(
                            identifier: "floatingActionButtonIdentifier",
                            isActive: $fabIsActive,
                            isPulsing: true
                        )
                    )

                Text("Rewards")
                    .tabBarItem(
                        .tab(
                            identifier: Tab.rewards,
                            icon: .interestCircle,
                            title: "Rewards"
                        )
                    )

                Text("Activity")
                    .tabBarItem(
                        .tab(
                            identifier: Tab.activity,
                            icon: .pending,
                            title: "Activity"
                        )
                    )
            }
        }
    }

    struct ExchangePreviewContainer: View {
        enum Tab: Hashable {
            case home
            case trade
            case portfolio
            case history
            case account
        }

        @State var activeTabIdentifier: AnyHashable

        var body: some View {
            TabBar(activeTabIdentifier: $activeTabIdentifier) {
                Text("Home")
                    .tabBarItem(
                        .tab(
                            identifier: Tab.home,
                            icon: .home,
                            title: "Home"
                        )
                    )

                Text("Trade")
                    .tabBarItem(
                        .tab(
                            identifier: Tab.trade,
                            icon: .swap,
                            title: "Trade"
                        )
                    )

                Text("Portfolio")
                    .tabBarItem(
                        .tab(
                            identifier: Tab.portfolio,
                            icon: .portfolio,
                            title: "Portfolio"
                        )
                    )

                Text("History")
                    .tabBarItem(
                        .tab(
                            identifier: Tab.history,
                            icon: .pending,
                            title: "History"
                        )
                    )

                Text("Account")
                    .tabBarItem(
                        .tab(
                            identifier: Tab.account,
                            icon: .user,
                            title: "Account"
                        )
                    )
            }
        }
    }
}
