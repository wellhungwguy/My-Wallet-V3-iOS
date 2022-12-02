import BlockchainComponentLibrary
import BlockchainNamespace
import FeatureCoinDomain
import Localization
import SwiftUI
import UIComponentsKit

struct RecurringBuySummaryView: View {

    private typealias L10n = LocalizationConstants.Coin.RecurringBuy.Summary

    @BlockchainApp var app
    @State var isBottomSheetPresented: Bool = false
    @Environment(\.context) var context
    @Environment(\.presentationMode) private var presentationMode

    let buy: RecurringBuy

    var body: some View {
        PrimaryNavigationView {
            VStack(alignment: .center, spacing: .zero) {
                ScrollView {
                    TableRow(
                        title: L10n.amount,
                        trailing: {
                            TableRowTitle(buy.amount)
                        }
                    )
                    PrimaryDivider()
                    TableRow(
                        title: L10n.crypto,
                        trailing: {
                            TableRowTitle(buy.asset)
                        }
                    )
                    PrimaryDivider()
                    TableRow(
                        title: L10n.paymentMethod,
                        trailing: {
                            TableRowTitle(buy.paymentMethodType)
                        }
                    )
                    PrimaryDivider()
                    TableRow(
                        title: L10n.frequency,
                        trailing: {
                            TableRowTitle(buy.recurringBuyFrequency)
                        }
                    )
                    PrimaryDivider()
                    TableRow(
                        title: L10n.nextBuy,
                        trailing: {
                            TableRowTitle(buy.nextPaymentDate)
                        }
                    )
                }
                VStack(spacing: 0) {
                    DestructiveMinimalButton(title: L10n.remove) {
                        isBottomSheetPresented = true
                    }
                }
                .padding()
                .backgroundWithShadow(.top)
            }
            .primaryNavigation(title: L10n.title) {
                IconButton(icon: .closeCirclev2) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .bottomSheet(isPresented: $isBottomSheetPresented) {
            RecurringBuyDeletionConfirmationView()
        }
    }
}

struct RecurringBuyDeletionConfirmationView: View {

    @BlockchainApp var app
    @Environment(\.presentationMode) private var presentationMode

    private typealias L10n = LocalizationConstants.Coin.RecurringBuy.Summary.Removal

    var body: some View {
        ActionableView(
            buttons: [
                .init(
                    title: L10n.remove,
                    action: {
                        app.post(
                            event: blockchain.ux.asset.recurring.buy.summary.cancel.tapped
                        )
                    },
                    style: .destructive
                )
            ],
            content: {
                VStack(spacing: 24) {
                    ZStack(alignment: .topTrailing) {
                        Icon.delete
                            .circle()
                            .color(.semantic.primary)
                            .frame(width: 88, height: 88)
                        Circle()
                            .fill(.white)
                            .frame(width: 36.0, height: 36.0)
                            .overlay(
                                Icon.alert
                                    .color(.semantic.warning)
                                    .frame(width: 34.0, height: 24.0)
                            )
                            .offset(x: 8.0, y: -8.0)
                    }
                    Text(L10n.title)
                        .typography(.title3)
                        .multilineTextAlignment(.center)
                }
            }
        )
    }
}

struct RecurringBuySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringBuySummaryView(
            buy: .init(
                id: "123",
                recurringBuyFrequency: "Once a Week",
                nextPaymentDate: "Next Monday",
                paymentMethodType: "Cash Wallet",
                amount: "$20.00",
                asset: "Bitcoin"
            )
        )
    }
}
