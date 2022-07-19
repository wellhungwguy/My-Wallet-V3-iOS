// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI

struct ActivityDetailsView: View {

    typealias L10n = LocalizationConstants.CardIssuing.Manage.Activity
    let store: Store<Card.Transaction?, CardManagementAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                header
                content(viewStore.state)
            }
        }
    }

    @ViewBuilder func content(_ transaction: Card.Transaction?) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                if let transaction = transaction {
                    transactionAmount(transaction)
                    Group {
                        DetailsRow(
                            leadingTitle: L10n.DetailSections.merchant,
                            trailingTitle: transaction.displayTitle
                        )
                        PrimaryDivider()
                        DetailsRow(
                            leadingTitle: L10n.DetailSections.type,
                            trailingTitle: transaction.transactionType.displayString
                        )
                        PrimaryDivider()
                        DetailsRow(
                            leadingTitle: L10n.DetailSections.dateTime,
                            trailingTitle: transaction.displayDate,
                            trailingSubtitle: transaction.displayTime
                        )
                        PrimaryDivider()
                        DetailsRow(
                            leadingTitle: L10n.DetailSections.paymentMethod,
                            trailingTitle: transaction.counterAmount?.symbol ??
                                transaction.originalAmount.symbol
                        )
                        PrimaryDivider()
                        DetailsRow(
                            leadingTitle: L10n.DetailSections.feesTitle,
                            trailingTitle: transaction.fee.displayString,
                            leadingSubtitle: L10n.DetailSections.feesDescription
                        )
                        PrimaryDivider()
                    }
                    clearedFundingAmount(transaction)
                    Group {
                        DetailsRow(
                            leadingTitle: .title(L10n.status),
                            trailingTitle: .custom(
                                transaction.displayStatus,
                                transaction.statusColor,
                                .body2
                            )
                        )
                        PrimaryDivider()
                    }
                }
                WithViewStore(store) { viewStore in
                    SmallMinimalButton(title: L10n.Button.help, action: {
                        viewStore.send(.showSupportFlow)
                    })
                    .padding(Spacing.padding2)
                }
            }
        }
        .frame(maxHeight: 60.vh)
    }

    @ViewBuilder func clearedFundingAmount(_ transaction: Card.Transaction) -> some View {
        if transaction.state == .completed,
           !transaction.clearedFundingAmount.isZero
        {
            Group {
                DetailsRow(
                    leadingTitle: L10n.DetailSections.adjustedPaymentTitle,
                    trailingTitle: transaction.clearedFundingAmount.displayString,
                    leadingSubtitle: L10n.DetailSections.adjustedPaymentDescription
                )
                PrimaryDivider()
                DetailsRow(
                    leadingSubtitle: .caption(L10n.DetailSections.initialAmount),
                    trailingSubtitle: .caption("-" + transaction.fundingAmount.displayString)
                )
                PrimaryDivider()
                DetailsRow(
                    leadingSubtitle: .caption(L10n.DetailSections.returnedAmount),
                    trailingSubtitle: .caption("+" + transaction.reversedAmount.displayString)
                )
                PrimaryDivider()
                DetailsRow(
                    leadingSubtitle: .custom(
                        L10n.DetailSections.settledAmount,
                        .semantic.title,
                        .caption1
                    ),
                    trailingSubtitle: .custom(
                        transaction.clearedFundingAmount.displayString,
                        .semantic.title,
                        .caption1
                    )
                )
                PrimaryDivider()
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder func transactionAmount(_ transaction: Card.Transaction) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.originalAmountDisplayString)
                    .typography(.title2)
                    .padding(.horizontal, Spacing.padding3)
                    .padding(.vertical, Spacing.padding2)
                Text(L10n.transactionDetails)
                    .typography(.paragraph2)
                    .padding(.horizontal, Spacing.padding3)
                    .foregroundColor(.semantic.muted)
                PrimaryDivider()
            }
        }
    }

    @ViewBuilder var header: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                HStack {
                    Text(
                        LocalizationConstants
                            .CardIssuing
                            .Manage
                            .Activity
                            .Navigation
                            .title
                    )
                    .typography(.title3)
                    .padding([.top], Spacing.padding1)
                    Spacer()
                    Icon.closeCirclev2
                        .frame(width: 24, height: 24)
                        .onTapGesture(perform: {
                            viewStore.send(.setTransactionDetailsVisible(false))
                        })
                }
            }
            .padding([.trailing, .leading], Spacing.padding3)
        }
    }
}

#if DEBUG

struct ActivityDetails_Previews: PreviewProvider {

    static var reducer = Reducer<Card.Transaction?, CardManagementAction, CardManagementEnvironment> { _, _, _ in
        .none
    }

    static var previews: some View {
        Rectangle()
            .bottomSheet(isPresented: .constant(true)) {
                ActivityDetailsView(
                    store: Store(
                        initialState: Card.Transaction.success,
                        reducer: ActivityDetails_Previews.reducer,
                        environment: .preview
                    )
                )
            }
    }
}

#endif

extension Card.Transaction.TransactionType {

    var displayString: String {
        typealias L10n = LocalizationConstants.CardIssuing.Manage.Transaction.TransactionType
        switch self {
        case .cashback:
            return L10n.cashback
        case .chargeback:
            return L10n.chargeback
        case .refund:
            return L10n.refund
        case .payment, .funding:
            return L10n.payment
        }
    }
}
