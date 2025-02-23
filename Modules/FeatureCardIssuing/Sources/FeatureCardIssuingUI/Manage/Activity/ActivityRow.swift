// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SceneKit
import SwiftUI
import ToolKit

struct ActivityRow: View {

    let merchant: String
    let amount: String
    let counterAmount: String
    let date: String
    let icon: Icon
    let tag: TagView
    let action: () -> Void

    init(
        merchant: String,
        amount: String,
        counterAmount: String,
        date: String,
        icon: Icon,
        tag: TagView,
        action: @escaping () -> Void
    ) {
        self.merchant = merchant
        self.amount = amount
        self.counterAmount = counterAmount
        self.date = date
        self.icon = icon
        self.tag = tag
        self.action = action
    }

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.padding2) {
            icon
                .color(.semantic.muted)
                .frame(width: 20, height: 20, alignment: .center)
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .center) {
                    Text(merchant)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                    Spacer()
                    Text(amount)
                        .typography(.body2)
                        .foregroundColor(.WalletSemantic.title)
                }
                HStack(alignment: .center) {
                    tag
                    Spacer()
                    Text(counterAmount)
                        .typography(.paragraph1)
                        .foregroundColor(.WalletSemantic.muted)
                }
            }
        }
        .padding()
        .background(Color.semantic.background)
        .onTapGesture {
            action()
        }
    }
}

extension ActivityRow {

    init(_ transaction: Card.Transaction, action: @escaping () -> Void) {
        self.merchant = transaction.displayTitle
        self.amount = transaction.displayString(for: transaction.displayAmount)
        self.counterAmount = transaction.displayString(for: transaction.counterAmount)
        self.date = transaction.displayDate
        self.icon = transaction.icon
        self.tag = transaction.tag
        self.action = action
    }
}

extension Card.Transaction {

    func displayString(for amount: Money?) -> String {
        guard let amount else {
            return ""
        }
        switch transactionType {
        case .funding, .payment, .atmWithdrawal:
            return "-" + amount.displayString
        case .refund, .chargeback, .paymentWithCashback:
            return "+" + amount.displayString
        }
    }
}

#if DEBUG

extension Card.Transaction {

    static var success = Card.Transaction(
        id: "42",
        cardId: "42",
        type: .payment,
        state: .completed,
        originalAmount: Money(value: "100.000000", symbol: "USD"),
        displayAmount: Money(value: "100.000000", symbol: "USD"),
        fundingAmount: Money(value: "100.000000", symbol: "USD"),
        reversedAmount: Money(value: "0.000000", symbol: "USD"),
        clearedFundingAmount: Money(value: "0.000000", symbol: "USD"),
        userTransactionTime: Date(),
        merchantName: "Blockchain.com",
        fee: Money(value: "0.000000", symbol: "USD")
    )

    static var pending = Card.Transaction(
        id: "43",
        cardId: "42",
        type: .payment,
        state: .pending,
        originalAmount: Money(value: "100.000000", symbol: "USD"),
        displayAmount: Money(value: "100.000000", symbol: "USD"),
        fundingAmount: Money(value: "100.000000", symbol: "USD"),
        reversedAmount: Money(value: "100.000000", symbol: "USD"),
        clearedFundingAmount: Money(value: "100.000000", symbol: "USD"),
        userTransactionTime: Date(),
        merchantName: "Blockchain.com",
        fee: Money(value: "100.000000", symbol: "USD")
    )

    static var failed = Card.Transaction(
        id: "43",
        cardId: "42",
        type: .payment,
        state: .declined,
        originalAmount: Money(value: "100.000000", symbol: "USD"),
        displayAmount: Money(value: "100.000000", symbol: "USD"),
        fundingAmount: Money(value: "100.000000", symbol: "USD"),
        reversedAmount: Money(value: "100.000000", symbol: "USD"),
        clearedFundingAmount: Money(value: "100.000000", symbol: "USD"),
        userTransactionTime: Date(),
        merchantName: "Blockchain.com",
        declineReason: "Not enough funds",
        fee: Money(value: "100.000000", symbol: "USD")
    )
}

struct ActivityRow_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    PrimaryDivider()
                    ActivityRow(
                        merchant: "Blockchain.com",
                        amount: "$100.00",
                        counterAmount: "0.0000021 BTC",
                        date: "Jun 17",
                        icon: Icon.walletSend.circle(),
                        tag: TagView(text: "Success", variant: .success),
                        action: {}
                    )
                    PrimaryDivider()
                    ActivityRow(
                        merchant: "Blockchain.com",
                        amount: "$100.00",
                        counterAmount: "",
                        date: "Jun 17",
                        icon: Icon.walletSend.circle(),
                        tag: TagView(text: "Pending", variant: .infoAlt),
                        action: {}
                    )
                }
            }
        }
    }
}
#endif
