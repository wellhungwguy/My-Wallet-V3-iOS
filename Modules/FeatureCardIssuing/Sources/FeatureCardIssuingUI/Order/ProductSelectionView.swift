// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct ProductSelectionView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                if !viewStore.state.products.isEmpty {
                    TabView(selection: viewStore.binding(
                        get: \.selectedProductIndex,
                        send: CardOrderingAction.selectProduct(_:)
                    )) {
                        ForEach(viewStore.state.products) { product in
                            ProductView(
                                product: product,
                                action: {
                                    viewStore.send(.binding(.set(\.$isProductDetailsVisible, true)))
                                }
                            )
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                }
                HStack {
                    Checkbox(
                        isOn: viewStore.binding(
                            get: { state in
                                state.acceptLegalState.accepted.value ?? false
                            },
                            send: CardOrderingAction.setLegalAccepted
                        )
                    )
                    Text(LocalizationConstants.CardIssuing.Legal.Item.title)
                        .foregroundColor(.WalletSemantic.body)
                        .typography(.caption1)
                        .onTapGesture {
                            viewStore.send(.binding(.set(\.$acceptLegalVisible, true)))
                        }
                }
                PrimaryButton(title: L10n.Selection.Button.Title.create) {
                    viewStore.send(.createCard)
                }
                .disabled(
                    !(viewStore.state.acceptLegalState.accepted.value ?? false)
                    || viewStore.state.products.isEmpty
                )
            }
            .padding(Spacing.padding3)
            .bottomSheet(isPresented: viewStore.binding(\.$isProductDetailsVisible)) {
                IfLetStore(
                    store.scope(state: \.selectedProduct),
                    then: { store in
                        ProductDetailsView(
                            store: store,
                            close: {
                                viewStore.send(.binding(.set(\.$isProductDetailsVisible, false)))
                            }
                        )
                    },
                    else: EmptyView.init
                )
            }
            .sheet(isPresented: viewStore.binding(\.$acceptLegalVisible)) {
                AcceptLegalView(
                    store: store.scope(
                        state: \.acceptLegalState,
                        action: CardOrderingAction.acceptLegalAction
                    )
                )
            }
            PrimaryNavigationLink(
                destination: OrderProcessingView(store: store),
                isActive: viewStore.binding(\.$isOrderProcessingVisible),
                label: EmptyView.init
            )
        }
        .primaryNavigation(title: L10n.Selection.Navigation.title)
    }
}

struct ProductView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order

    private let product: Product
    private let action: () -> Void

    init(
        product: Product,
        action: @escaping () -> Void
    ) {
        self.product = product
        self.action = action
    }

    var body: some View {
        VStack {
            Image("card-selection", bundle: .cardIssuing)
                .resizable()
                .scaledToFit()
            VStack(spacing: Spacing.padding1) {
                Text(product.type.localizedTitle)
                    .typography(.title2)
                    .multilineTextAlignment(.center)
                Text(product.type.localizedDescription)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
            }
            SmallMinimalButton(
                title: L10n.Selection.Button.Title.details,
                action: action
            )
            .padding(.bottom, Spacing.padding4)
        }
    }
}

#if DEBUG
struct ProductSelection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductSelectionView(
                store: Store(
                    initialState: .init(),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif

extension Card.CardType {

    var localizedTitle: String {
        typealias L10n = LocalizationConstants.CardIssuing.CardType
        switch self {
        case .physical:
            return L10n.Physical.title
        case .virtual:
            return L10n.Virtual.title
        }
    }

    var localizedLongTitle: String {
        typealias L10n = LocalizationConstants.CardIssuing.CardType
        switch self {
        case .physical:
            return L10n.Physical.longTitle
        case .virtual:
            return L10n.Virtual.longTitle
        }
    }

    var localizedDescription: String {
        typealias L10n = LocalizationConstants.CardIssuing.CardType
        switch self {
        case .physical:
            return L10n.Physical.description
        case .virtual:
            return L10n.Virtual.description
        }
    }
}
