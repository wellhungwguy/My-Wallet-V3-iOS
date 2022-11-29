// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI

struct ReviewOrderView: View {

    struct TitleView: View {
        let title: String

        var body: some View {
            HStack {
                Text(title)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.text)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.top, Spacing.padding1)
        }
    }

    fileprivate typealias L10n = LocalizationConstants.CardIssuing.Order.Review

    let store: Store<CardOrderingState, CardOrderingAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding2) {
                ScrollView {
                    HStack {
                        Text(L10n.instruction)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.muted)
                        Spacer()
                    }
                    .padding(.bottom, Spacing.padding3)
                    TitleView(title: L10n.Section.FullName.title)
                    TableRow(
                        title: viewStore.state.fullname,
                        byline: L10n.Section.FullName.description
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.padding1)
                            .stroke(Color.semantic.light, lineWidth: 1)
                    )
                    .onTapGesture {
                        viewStore.send(CardOrderingAction.showSupportFlow)
                    }
                    if viewStore.state.selectedProduct?.type == .physical {
                        TitleView(title: L10n.Section.ShippingAddress.title)
                        if let address = viewStore.state.shippingAddress ?? viewStore.state.address {
                            TableRow(
                                title: address.shortDisplayTitleString,
                                byline: address.shortDisplaySubtitleString,
                                trailing: {
                                    Icon.edit.color(.semantic.title).frame(width: 24)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.padding1)
                                    .stroke(Color.semantic.light, lineWidth: 1)
                            )
                            .onTapGesture {
                                viewStore.send(CardOrderingAction.editShippingAddress)
                            }
                        }
                    }
                    TitleView(title: L10n.Section.Product.title)
                    TableRow(
                        leading: {
                            viewStore.state
                                .selectedProduct?
                                .type
                                .image
                                .resizable()
                                .frame(width: 54, height: 88)
                        },
                        title: viewStore.state.selectedProduct?.type.localizedLongTitle ?? "",
                        byline: L10n.Section.Product.description,
                        trailing: {
                            Icon.edit.color(.semantic.title).frame(width: 24)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.padding1)
                            .stroke(Color.semantic.light, lineWidth: 1)
                    )
                    .onTapGesture {
                        viewStore.send(.binding(.set(\.$isReviewVisible, false)))
                    }
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
                PrimaryButton(title: L10n.Button.create) {
                    viewStore.send(.createCard)
                }
                .disabled(
                    !(viewStore.state.acceptLegalState.accepted.value ?? false)
                    || viewStore.state.products.isEmpty
                )
            }
            .padding(Spacing.padding3)
            .onAppear {
                viewStore.send(CardOrderingAction.fetchFullName)
            }
            PrimaryNavigationLink(
                destination: OrderProcessingView(store: store),
                isActive: viewStore.binding(\.$isOrderProcessingVisible),
                label: EmptyView.init
            )
        }
        .navigationTitle(L10n.navigationTitle)
    }
}

#if DEBUG
struct ReviewOrderView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewOrderView(
            store: .init(
                initialState: .init(),
                reducer: cardOrderingReducer,
                environment: .preview
            )
        )
    }
}
#endif

extension LocalizationConstants.CardIssuing.Order {

    enum Review {

        static let instruction = NSLocalizedString(
            """
            Please review the information below, if correct \
            accept the terms to finalize your order
            """,
            comment: "CIP: Review instructions"
        )

        static let navigationTitle = NSLocalizedString(
            "Review and Submit",
            comment: "CIP: Review and Submit navigation title"
        )

        enum Button {

            static let create = NSLocalizedString(
                "Create Card",
                comment: "Card Issuing: Create card button"
            )
        }

        enum Section {

            enum FullName {
                static let title = NSLocalizedString(
                    "Full Name",
                    comment: "Card Issuing: Create card button"
                )

                static let description = NSLocalizedString(
                    "Want to update your name? Contact Us →",
                    comment: "CIP: Review Contact Us"
                )
            }

            enum ShippingAddress {
                static let title = NSLocalizedString(
                    "Shipping Address",
                    comment: "Card Issuing: Shipping Address title"
                )
            }

            enum Product {
                static let title = NSLocalizedString(
                    "Card Selected",
                    comment: "Card Issuing: Card Selected title"
                )
                static let description = NSLocalizedString(
                    "Blockchain.com Visa® Card",
                    comment: "CIP: Card description"
                )
            }
        }
    }
}
