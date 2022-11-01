// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import SwiftUI

@available(iOS 16.0, *)
struct InteractiveMultiAppContent: View {
    /// The current total balance
    @Binding var totalBalance: String
    /// The current selected app mode
    @Binding var currentModeSelection: AppMode
    /// The content offset for the modal sheet
    @Binding var contentOffset: ModalSheetContext
    /// The scroll offset for the inner scroll view, not currently used...
    @Binding var scrollOffset: CGPoint

    @State private var selectedDetent = SwiftUI.PresentationDetent.collapsed
    /// `True` when a pull to refresh is triggered, otherwise `false`
    @Binding var isRefreshing: Bool

    var body: some View {
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
        .sheet(isPresented: .constant(true), content: {
            MultiAppContentView(
                scrollOffset: $scrollOffset,
                selectedDetent: $selectedDetent,
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
            .presentationDetents(
                [
                    .collapsed,
                    .expanded
                ],
                selection: $selectedDetent
            )
            .presentationDragIndicator(.hidden)
            // the "Custom:CollpsedDetent" is the name the system gives to a custom detent
            .largestUndimmedDetentIdentifier("Custom:CollapsedDetent", modalOffset: $contentOffset)
            .interactiveDismissDisabled(true)
        })
    }
}

// MARK: - For Demo purposes

struct _Tab: Hashable {
    let id: Int
    let selectedIcon: Icon
    let unselectedIcon: Icon
    let title: String
}

private let tradingTabs = [
    _Tab(
        id: 0,
        selectedIcon: Icon.homeFilled,
        unselectedIcon: Icon.home,
        title: "Home"
    ),
    _Tab(
        id: 1,
        selectedIcon: Icon.trade,
        unselectedIcon: Icon.trade,
        title: "Trade"
    ),
    _Tab(
        id: 2,
        selectedIcon: Icon.cardFilled,
        unselectedIcon: Icon.card,
        title: "Card"
    )
]

private let defiTabs = [
    _Tab(
        id: 0,
        selectedIcon: Icon.homeFilled,
        unselectedIcon: Icon.home,
        title: "Home"
    ),
    _Tab(
        id: 1,
        selectedIcon: Icon.pricesFilled,
        unselectedIcon: Icon.prices,
        title: "Prices"
    ),
    _Tab(
        id: 2,
        selectedIcon: Icon.nftFilled,
        unselectedIcon: Icon.nft,
        title: "NFTs"
    )
]

// TODO: Move/Replace this with real content view
struct MultiAppTradingView: View {
    @State private var selection: _Tab = tradingTabs[0]

    private var tabs: [BottomBarItem<_Tab>] {
        tradingTabs.map {
            BottomBarItem<_Tab>.init(
                id: $0,
                selectedIcon: $0.selectedIcon.renderingMode(.original),
                unselectedIcon: $0.unselectedIcon.renderingMode(.original),
                title: $0.title
            )
        }
    }

    var body: some View {
        TabView(
            selection: $selection,
            content: {
                dummyView(tabs: tabs)
            }
        )
        // iOS 16 provides the following natively
        //        .toolbar(.hidden, for: .tabBar)
        .introspectTabBarController(customize: { controller in
            controller.tabBar.isHidden = true
        })
        .overlay(
            VStack {
                Spacer()
                BottomBar(
                    selectedItem: $selection,
                    items: tabs
                )
                .cornerRadius(100)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 10, y: 5)
                .padding(
                    EdgeInsets(
                        top: 0,
                        leading: 40,
                        bottom: 0,
                        trailing: 40
                    )
                )
            }
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    func dummyView(tabs: [BottomBarItem<_Tab>]) -> some View {
        ForEach(tabs) { tab in
            DummyInnerContentView(tab: tab)
                .tag(tab.id)
                .id(tab.id)
                .accessibilityIdentifier("tab.id.\(tab.id)")
        }
    }
}

struct DummyInnerContentView: View {
    let tab: BottomBarItem<_Tab>

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(0..<20) { value in
                        PrimaryRow(
                            title: "\(tab.title) \(value)",
                            subtitle: "Buy & Sell",
                            action: {}
                        )
                    }
                }
                .padding(.bottom, Spacing.padding6)
                .navigationTitle(tab.title)
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// TODO: Move/Replace this with real content view
struct MultiAppDefiView: View {
    @State private var selection: _Tab = defiTabs[0]

    private var tabs: [BottomBarItem<_Tab>] {
        defiTabs.map {
            BottomBarItem<_Tab>.init(
                id: $0,
                selectedIcon: $0.selectedIcon.renderingMode(.original),
                unselectedIcon: $0.unselectedIcon.renderingMode(.original),
                title: $0.title
            )
        }
    }

    var body: some View {
        TabView(
            selection: $selection,
            content: {
                dummyView(tabs: tabs)
            }
        )
        .introspectTabBarController(customize: { controller in
            controller.tabBar.isHidden = true
        })
        .overlay(
            VStack {
                Spacer()
                BottomBar(
                    selectedItem: $selection,
                    items: tabs
                )
                .cornerRadius(100)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 10, y: 5)
                .padding(
                    EdgeInsets(
                        top: 0,
                        leading: 40,
                        bottom: 0,
                        trailing: 40
                    )
                )
            }
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    func dummyView(tabs: [BottomBarItem<_Tab>]) -> some View {
        ForEach(tabs) { tab in
            DummyInnerContentView(tab: tab)
                .tag(tab.id)
                .id(tab.id)
                .accessibilityIdentifier("tab.id.\(tab.id)")
        }
    }
}
