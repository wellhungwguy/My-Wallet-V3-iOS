// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct ResidentialAddressConfirmationView: View {

    private typealias L10n = LocalizationConstants.CardIssuing.Order.KYC

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                VStack(alignment: .leading, spacing: Spacing.padding1) {
                    Text(L10n.Address.title)
                        .typography(.title3)
                        .multilineTextAlignment(.center)
                    Text(L10n.Address.description)
                        .typography(.paragraph1)
                        .foregroundColor(.WalletSemantic.body)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, Spacing.padding2)
                VStack {
                    PrimaryDivider()
                    PrimaryRow(
                        title: L10n.Address.Navigation.title,
                        subtitle: viewStore.state.address?.shortDisplayString,
                        leading: { EmptyView() },
                        action: {
                            viewStore.send(.binding(.set(\.$isAddressModificationVisible, true)))
                        }
                    )
                    PrimaryDivider()
                }
                Spacer()
                PrimaryButton(title: L10n.Buttons.next) {
                    viewStore.send(.binding(.set(\.$isSSNInputVisible, true)))
                }
                .disabled(viewStore.state.address == .none)
                .padding(Spacing.padding2)
            }
            .padding(.vertical, Spacing.padding3)
            .primaryNavigation(title: L10n.Address.Navigation.title)
            .onAppear {
                viewStore.send(.fetchAddress)
            }

            PrimaryNavigationLink(
                destination: SSNInputView(store: store),
                isActive: viewStore.binding(\.$isSSNInputVisible),
                label: EmptyView.init
            )
            PrimaryNavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: \.residentialAddressModificationState,
                        action: CardOrderingAction.residentialAddressModificationAction
                    ),
                    then: { store in
                        ResidentialAddressModificationView(store: store)
                    }
                ),
                isActive: viewStore
                    .binding(\.$isAddressModificationVisible),
                label: EmptyView.init
            )
        }
    }
}

#if DEBUG
struct ResidentialAddressConfirmation_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResidentialAddressConfirmationView(
                store: Store(
                    initialState: CardOrderingState(address: MockServices.address),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif

extension Card.Address {
    var shortDisplayString: String {
        [
            line1,
            line2,
            city,
            state?
                .replacingOccurrences(
                    of: Card.Address.Constants.usPrefix,
                    with: ""
                )
        ]
        .filter(\.isNotNilOrEmpty)
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}
