import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI

public struct AppModeSwitcherView: View {

    private var onClose: () -> Void

    let store: Store<AppModeSwitcherState, AppModeSwitcherAction>
    @ObservedObject var viewStore: ViewStore<AppModeSwitcherState, AppModeSwitcherAction>

    public init(
        store: Store<AppModeSwitcherState, AppModeSwitcherAction>,
        onClose: @escaping () -> Void
    ) {
        self.store = store
        viewStore = ViewStore(store)
        self.onClose = onClose
    }

    public var body: some View {
        VStack {
            headerView
            selectionView
        }
        .background(Color.clear)
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.padding1, content: {
                Text("Your total balance")
                    .typography(.caption2)
                    .foregroundColor(.semantic.title)

                Text(viewStore.totalAccountBalance ?? "")
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
                title: "Brokerage",
                caption: nil,
                subtitle: viewStore.brokerageAccountBalance ?? ""
            ) {
                Icon
                    .portfolio
                    .frame(width: 24, height: 24)
            } trailing: {
                if viewStore.currentAppMode == .trading {
                    checkMarkIcon
                } else {
                    chevronIcon
                }
            } action: {
                viewStore.send(.onBrokerageTapped)
                onClose()
            }

            PrimaryRow(
                title: "Defi Wallet",
                caption: nil,
                subtitle: viewStore.defiAccountBalance ?? ""
            ) {
                Icon
                    .wallet
                    .accentColor(.semantic.defi)
                    .frame(width: 24, height: 24)
            } trailing: {
                if viewStore.currentAppMode == .defi {
                    checkMarkIcon
                } else {
                    chevronIcon
                }
            } action: {
                viewStore.send(.onDefiTapped)
                onClose()
            }
        }
        .padding(.bottom, Spacing.padding6)
    }

    private var chevronIcon: some View {
        Icon
            .chevronRight
            .frame(width: 24, height: 24)
            .accentColor(.semantic.muted)
    }

    private var checkMarkIcon: some View {
        Icon
            .checkCircle
            .renderingMode(.template)
            .frame(width: 24, height: 24)
            .accentColor(.semantic.primary)
    }
}
