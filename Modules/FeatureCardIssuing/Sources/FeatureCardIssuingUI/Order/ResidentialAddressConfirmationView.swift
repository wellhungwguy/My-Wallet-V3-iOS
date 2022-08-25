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
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: Spacing.padding3) {
                    Text(L10n.Address.description)
                        .typography(.paragraph1)
                        .foregroundColor(.WalletSemantic.body)
                        .multilineTextAlignment(.leading)
                    Text(L10n.Address.title)
                        .typography(.paragraph2)
                        .foregroundColor(.WalletSemantic.title)
                        .multilineTextAlignment(.leading)
                }
                VStack() {
                    PrimaryRow(
                        title: viewStore.state.address?.shortDisplayTitleString ?? "",
                        subtitle: viewStore.state.address?.shortDisplaySubtitleString,
                        trailing: {
                            SmallMinimalButton(title: L10n.Buttons.edit, action: {
                                viewStore.send(.editAddress)
                            })
                        }
                    )
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.WalletSemantic.medium, lineWidth: 0.5)
                )
                Text(L10n.Address.commericalAddressNotAccepted)
                    .typography(.caption1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.leading)
                Spacer()
                PrimaryButton(title: L10n.Buttons.next) {
                    viewStore.send(.binding(.set(\.$isSSNInputVisible, true)))
                }
                .disabled(!(viewStore.state.address?.hasAllRequiredInformation ?? false))
                .padding(Spacing.padding2)
            }
            .padding(.vertical, Spacing.padding3)
            .padding(.horizontal, Spacing.padding2)
            .primaryNavigation(title: L10n.Address.Navigation.title)
            .onAppear {
                viewStore.send(.fetchAddress)
            }

            PrimaryNavigationLink(
                destination: SSNInputView(store: store),
                isActive: viewStore.binding(\.$isSSNInputVisible),
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
    fileprivate var shortDisplayTitleString: String {
        [
            line1,
            line2
        ]
            .filter(\.isNotNilOrEmpty)
            .compactMap { $0 }
            .joined(separator: " ")
    }

    fileprivate var shortDisplaySubtitleString: String {
        let firstPart: String = [
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
        return [
            firstPart,
            postCode
        ].filter(\.isNotNilOrEmpty)
            .compactMap { $0 }
            .joined(separator: " ")
    }
}

extension Card.Address {
    fileprivate var hasAllRequiredInformation: Bool {
        line1.isNotNilOrEmpty
        && city.isNotNilOrEmpty
        && postCode.isNotNilOrEmpty
        && country.isNotNilOrEmpty
    }
}
