// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import DIKit
import FeatureDashboardUI
import SwiftUI

@available(iOS 16.0, *)
struct InteractiveMultiAppContent: View {
    @BlockchainApp var app
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

    @State private var hideBalanceAfterRefresh = false

    private let supportedDetents = AppChromeDetents.supportedDetents

    var body: some View {
        MultiAppHeaderView(
            totalBalance: $totalBalance,
            currentSelection: $currentModeSelection,
            contentOffset: $contentOffset,
            scrollOffset: $scrollOffset,
            isRefreshing: $isRefreshing
        )
        .onChange(of: currentModeSelection, perform: { newValue in
            app.post(value: newValue.rawValue, of: blockchain.app.mode)
        })
        .onChange(of: isRefreshing, perform: { _ in
            if !isRefreshing {
                hideBalanceAfterRefresh.toggle()
            }
        })
        .task(id: hideBalanceAfterRefresh) {
            // run initial "animation" and select `semiCollapsed` detent after 3 second
            do {
                try await Task.sleep(until: .now + .seconds(3), clock: .continuous)
                selectedDetent = .semiCollapsed
            } catch {}
        }
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
            .background(
                Color.semantic.light
            )
            .frame(maxWidth: .infinity)
            .presentationDetents(
                Set(supportedDetents.map(\.detent)),
                selection: $selectedDetent
            )
            .presentationDragIndicator(.hidden)
            .largestUndimmedDetentIdentifier(
                AppChromeDetents.semiCollapsed.identifier,
                modalOffset: $contentOffset
            ) { identifier in
                if let first = supportedDetents.first(where: { $0.identifier == identifier }) {
                    selectedDetent = first.detent
                }
            }
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
        selectedIcon: Icon.multiAppHomeFilled,
        unselectedIcon: Icon.multiAppHome,
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
        selectedIcon: Icon.multiAppCardFilled,
        unselectedIcon: Icon.multiAppCard,
        title: "Card"
    )
]

private let defiTabs = [
    _Tab(
        id: 0,
        selectedIcon: Icon.multiAppHomeFilled,
        unselectedIcon: Icon.multiAppHome,
        title: "Home"
    ),
    _Tab(
        id: 1,
        selectedIcon: Icon.multiAppPricesFilled,
        unselectedIcon: Icon.multiAppPrices,
        title: "Prices"
    ),
    _Tab(
        id: 2,
        selectedIcon: Icon.multiAppNftFilled,
        unselectedIcon: Icon.multiAppNft,
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
            TradingDashboardView(store: .init(
                initialState: .init(title: tab.title),
                reducer: TradingDashboard(
                    app: resolve(),
                    allCryptoAssetService: resolve()
                )
            )
            )
                .tag(tab.id)
                .id(tab.id)
                .accessibilityIdentifier("tab.id.\(tab.id)")
                .background(Color.semantic.light)
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
            PKWDashboardView(store: .init(
                initialState: .init(title: tab.title),
                reducer: PKWDashboard(
                    app: resolve(),
                    allCryptoAssetService: resolve(),
                    activityRepository: resolve()
                )
            )
            )
                .tag(tab.id)
                .id(tab.id)
                .accessibilityIdentifier("tab.id.\(tab.id)")
        }
    }
}
