// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableArchitectureExtensions
import Errors
import FeatureCardIssuingDomain
import Localization
import SwiftUI

struct CardStatusView: View {

    let store: Store<CardManagementState, CardManagementAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            if let fulfillment = viewStore.state.fulfillment {
                HStack(spacing: 12) {
                    fulfillment.status.icon
                        .frame(width: 24, height: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(fulfillment.status.title)
                            .typography(.body2)
                        Text(fulfillment.status.subtitle)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.muted)
                    }
                    Spacer()
                    if fulfillment.status == .shipped || fulfillment.status == .delivered {
                        Icon.chevronRight
                            .color(.semantic.muted)
                            .frame(width: 24, height: 18)
                    }
                }
                .frame(width: .infinity)
                .padding(.horizontal, Spacing.padding2)
                .padding(.vertical, Spacing.padding2)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(fulfillment.status.borderColor, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                .padding(.horizontal, Spacing.padding2)
                .padding(.bottom, Spacing.padding1)
                .onTapGesture {
                    viewStore.send(.getActivationUrl)
                }
            } else {
                EmptyView()
            }
        }
    }
}

extension Card.Fulfillment.Status {

    var icon: Icon {
        switch self {
        case .delivered:
            return Icon.creditcard.color(.semantic.body)
        case .processing, .processed:
            return Icon.pending
        case .shipped:
            return Icon.send
        }
    }

    var borderColor: Color {
        switch self {
        case .delivered:
            return .semantic.body
        default:
            return .clear
        }
    }

    var title: String {
        typealias L10n = LocalizationConstants.CardIssuing.Fulfillment.Status
        switch self {
        case .processing, .processed:
            return L10n.Ordered.title
        case .delivered:
            return L10n.Delivered.title
        case .shipped:
            return L10n.Shipped.title
        }
    }

    var subtitle: String {
        typealias L10n = LocalizationConstants.CardIssuing.Fulfillment.Status
        switch self {
        case .processing, .processed:
            return L10n.Ordered.subtitle
        case .delivered:
            return L10n.Delivered.subtitle
        case .shipped:
            return L10n.Shipped.subtitle
        }
    }
}

extension LocalizationConstants.CardIssuing {

    enum Fulfillment {

        enum Status {

            enum Ordered {

                static let title = NSLocalizedString(
                    "Processing Order",
                    comment: "Card Issuing: Status Ordered"
                )

                static let subtitle = NSLocalizedString(
                    "Confirming your details",
                    comment: "Card Issuing: Confirming your details"
                )
            }

            enum Shipped {

                static let title = NSLocalizedString(
                    "Card Shipped",
                    comment: "Card Issuing: Status Shipped"
                )

                static let subtitle = NSLocalizedString(
                    "Delivered? Activate your card",
                    comment: "Card Issuing: Delivered? Activate your card"
                )
            }

            enum Delivered {

                static let title = NSLocalizedString(
                    "Card Delivered",
                    comment: "Card Issuing: Status Delivered"
                )

                static let subtitle = NSLocalizedString(
                    "Activate your card",
                    comment: "Card Issuing: Activate your card"
                )
            }
        }
    }
}
