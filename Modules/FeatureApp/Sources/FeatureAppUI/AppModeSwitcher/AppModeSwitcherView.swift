import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI

public struct AppModeSwitcherView: View {
    let store: Store<AppModeSwitcherState, AppModeSwitcherAction>
    @ObservedObject var viewStore: ViewStore<AppModeSwitcherState, AppModeSwitcherAction>

    public init(
        store: Store<AppModeSwitcherState, AppModeSwitcherAction>
    ) {
        self.store = store
        viewStore = ViewStore(store)
        viewStore.send(.onInit)
    }

    public var body: some View {
        VStack {
            headerView
            selectionView
        }
        .sheet(
            isPresented: viewStore.binding(\.$defiWalletState.isDefiIntroPresented),
            content: {
                let store = store.scope(
                    state: \.defiWalletState,
                    action: AppModeSwitcherAction.defiWalletIntro
                )
                PrimaryNavigationView {
                    DefiWalletIntroView(store: store)
                }
            }
        )
        .background(Color.clear)
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.padding1, content: {
                Text(LocalizationConstants.AppModeSwitcher.totalBalanceLabel)
                    .typography(.caption2)
                    .foregroundColor(.semantic.title)

                Text(viewStore
                    .totalAccountBalance?
                    .toDisplayString(includeSymbol: true) ?? "")
                .typography(.title2)
                .foregroundColor(.semantic.title)
            })
            .padding(.top, Spacing.padding2)
            .padding(.leading, Spacing.padding3)
            Spacer()
        }
    }

    private var selectionView: some View {
        VStack {
            PrimaryRow(
                title: AppMode.trading.displayName,
                caption: nil,
                subtitle: viewStore
                    .brokerageAccountBalance?
                    .toDisplayString(includeSymbol: true) ?? ""
            ) {
                Icon
                    .portfolio
                    .color(.semantic.primary)
                    .frame(width: 24, height: 24)
            } trailing: {
                if viewStore.currentAppMode == .trading {
                    checkMarkIcon
                } else {
                    chevronIcon
                }
            } action: {
                viewStore.send(.onTradingTapped)
            }

            PrimaryRow(
                title: AppMode.pkw.displayName,
                caption: nil,
                subtitle: defiSubtitleString,
                description: defiDescriptionString,
                leading: {
                    Icon
                        .wallet
                        .color(.semantic.defi)
                        .frame(width: 24, height: 24)
                },
                trailing: {
                    if viewStore.currentAppMode == .pkw {
                        checkMarkIcon
                    } else {
                        chevronIcon
                    }
                },
                action: {
                    viewStore.send(.onDefiTapped)
                }
            )
        }
        .padding(.bottom, Spacing.padding6)
    }

    private var defiSubtitleString: String {
        guard viewStore.shouldShowDefiModeIntro else {
            return viewStore
                .defiAccountBalance?
                .toDisplayString(includeSymbol: true) ?? ""
        }
        return LocalizationConstants.AppModeSwitcher.defiSubtitle
    }

    private var defiDescriptionString: String? {
        guard viewStore.shouldShowDefiModeIntro else {
            return nil
        }
        return LocalizationConstants.AppModeSwitcher.defiDescription
    }

    private var chevronIcon: some View {
        Icon
            .chevronRight
            .color(.semantic.muted)
            .frame(width: 24, height: 24)
    }

    private var checkMarkIcon: some View {
        Icon
            .checkCircle
            .renderingMode(.template)
            .color(.semantic.primary)
            .frame(width: 24, height: 24)
    }
}
