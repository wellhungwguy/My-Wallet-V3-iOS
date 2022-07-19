// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct ProductDetailsView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order.Details

    private let store: Store<Product, CardOrderingAction>
    private let close: () -> Void

    init(
        store: Store<Product, CardOrderingAction>,
        close: @escaping () -> Void
    ) {
        self.store = store
        self.close = close
    }

    var body: some View {
        LazyVStack(spacing: 0) {
            WithViewStore(store) { viewStore in
                HStack {
                    Text(viewStore.state.type.localizedLongTitle)
                        .typography(.title3)
                        .padding([.top, .leading], Spacing.padding1)
                    Spacer()
                    Icon.closeCirclev2
                        .frame(width: 24, height: 24)
                        .onTapGesture(perform: { close() })
                }
                .padding(.horizontal, Spacing.padding2)
                .padding(.bottom, Spacing.padding2)
                PrimaryDivider()
                PrimaryRow(
                    title: L10n.Fees.title,
                    subtitle: L10n.Fees.description,
                    leading: { icon(.flag) },
                    trailing: EmptyView.init,
                    action: {}
                )
                PrimaryDivider()
                PrimaryRow(
                    title: L10n.Rewards.title,
                    subtitle: L10n.Rewards.description,
                    leading: { icon(.present) },
                    trailing: EmptyView.init,
                    action: {}
                )
                PrimaryDivider()
                PrimaryRow(
                    title: L10n.Legal.title,
                    leading: { icon(.listBullets) },
                    action: {
                        viewStore.send(
                            .binding(.set(\.$isLegalViewVisible, true))
                        )
                    }
                )
            }
        }
    }

    @ViewBuilder func icon(_ icon: Icon) -> some View {
        VStack {
            icon
                .frame(width: 17, height: 17)
                .padding(.top, Spacing.padding2)
            Spacer()
        }
    }
}

#if DEBUG
struct ProductDetails_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .bottomSheet(isPresented: .constant(true)) {
                ProductDetailsView(
                    store: .init(
                        initialState: Product(
                            productCode: "42",
                            price: .init(value: "0", symbol: "BTC"),
                            brand: .visa,
                            type: .virtual
                        ),
                        reducer: Reducer<Product, CardOrderingAction, CardOrderingEnvironment>({ _, _, _ in
                            .none
                        }),
                        environment: .preview
                    ),
                    close: {}
                )
            }
    }
}
#endif
