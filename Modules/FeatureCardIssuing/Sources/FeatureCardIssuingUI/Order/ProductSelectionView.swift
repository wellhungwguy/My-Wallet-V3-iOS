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
    @State private var currentIndex = ""

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                if !viewStore.state.products.isEmpty {
                    TabView(selection: $currentIndex) {
                        ForEach(viewStore.state.products) { product in
                            ProductView(
                                product: product,
                                action: {
                                    viewStore.send(.binding(.set(\.$isProductDetailsVisible, true)))
                                }
                            )
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onChange(of: currentIndex) { index in
                        guard let product = viewStore.state.products.first(where: { product in
                            product.id == index
                        }) else {
                            return
                        }
                        viewStore.send(.selectProduct(product))
                    }
                    .onAppear {
                        currentIndex = viewStore.selectedProduct?.id ?? ""
                    }
                }
                if let index = viewStore.state.products.firstIndex(where: { product in
                    product.id == currentIndex
                }) {
                    PageControl(currentPage: index, numberOfPages: viewStore.state.products.count)
                }
                PrimaryButton(
                    title: viewStore.state.selectedProduct?.hasRemainingCards ?? true ?
                    L10n.Selection.Button.Title.continue
                    : L10n.Selection.Button.Title.currentlyActive
                ) {
                    viewStore.send(.binding(.set(\.$isReviewVisible, true)))
                }
                .disabled(!(viewStore.state.selectedProduct?.hasRemainingCards ?? false))
            }
            .padding(Spacing.padding3)
            .onAppear {
                viewStore.send(.fetchProducts)
            }
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
                destination: ReviewOrderView(store: store),
                isActive: viewStore.binding(\.$isReviewVisible),
                label: EmptyView.init
            )
        }
        .primaryNavigation(title: L10n.Selection.Navigation.title)
    }
}

struct PageControl: UIViewRepresentable {

    let currentPage: Int
    let numberOfPages: Int

    func makeUIView(context: Context) -> some UIPageControl {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor(.semantic.primary)
        pageControl.pageIndicatorTintColor = UIColor(.semantic.muted)
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPage
        return pageControl
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = currentPage
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
            product.type.image
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
        }
        .tag(product.id)
    }
}

#if DEBUG
struct ProductSelection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductSelectionView(
                store: Store(
                    initialState: .init(initialKyc: KYC(status: .success, errorFields: nil)),
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
        case .physical, .shadow:
            return L10n.Physical.title
        case .virtual:
            return L10n.Virtual.title
        }
    }

    var localizedLongTitle: String {
        typealias L10n = LocalizationConstants.CardIssuing.CardType
        switch self {
        case .physical, .shadow:
            return L10n.Physical.longTitle
        case .virtual:
            return L10n.Virtual.longTitle
        }
    }

    var localizedDescription: String {
        typealias L10n = LocalizationConstants.CardIssuing.CardType
        switch self {
        case .physical, .shadow:
            return L10n.Physical.description
        case .virtual:
            return L10n.Virtual.description
        }
    }
}
