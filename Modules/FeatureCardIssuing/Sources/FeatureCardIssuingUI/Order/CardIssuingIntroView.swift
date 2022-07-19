// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct CardIssuingIntroView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                Image("graphic-cards", bundle: .cardIssuing)
                    .resizable()
                    .scaledToFit()
                Text(L10n.Intro.title)
                    .typography(.title2)
                    .multilineTextAlignment(.center)
                Text(L10n.Intro.caption)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
                PrimaryButton(
                    title: L10n.Intro.Button.Title.order,
                    isLoading: viewStore.state.products.isEmpty,
                    action: {
                        viewStore.send(
                            .binding(.set(\.$isAddressConfirmationVisible, true))
                        )
                    }
                )
                .disabled(viewStore.state.products.isEmpty)
                PrimaryNavigationLink(
                    destination: ResidentialAddressConfirmationView(store: store),
                    isActive: viewStore.binding(\.$isAddressConfirmationVisible),
                    label: EmptyView.init
                )
                .padding(.top, Spacing.padding2)
                Spacer()
            }
            .onAppear {
                viewStore.send(.fetchProducts)
            }
            .padding(Spacing.padding3)
            .primaryNavigation(title: LocalizationConstants.CardIssuing.Navigation.title)
        }
    }
}

#if DEBUG
struct CardIssuingIntro_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardIssuingIntroView(
                store: Store(
                    initialState: .init(),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
            CardIssuingIntroView(
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
