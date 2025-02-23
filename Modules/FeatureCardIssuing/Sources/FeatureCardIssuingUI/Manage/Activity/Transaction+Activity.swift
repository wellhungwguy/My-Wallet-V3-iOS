// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainComponentLibrary
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

extension Card.Transaction {

    var displayDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: userTransactionTime)
    }

    var displayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: userTransactionTime)
    }

    var displayDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: userTransactionTime)
    }

    var displayTitle: String {
        [transactionType.displayString, merchantName].joined(separator: " ")
    }

    var displayStatus: String {
        typealias L10n = LocalizationConstants.CardIssuing.Manage.Transaction.Status
        switch state {
        case .pending, .created:
            return L10n.pending
        case .cancelled:
            return L10n.cancelled
        case .declined:
            return L10n.declined
        case .completed:
            return L10n.completed
        }
    }

    var statusColor: Color {
        switch state {
        case .pending, .created:
            return .WalletSemantic.muted
        case .cancelled:
            return .WalletSemantic.muted
        case .declined:
            return .WalletSemantic.error
        case .completed:
            return .WalletSemantic.success
        }
    }

    var icon: Icon {
        switch (state, transactionType) {
        case (.pending, _), (.created, _):
            return Icon.pending
        case (.cancelled, _):
            return Icon.error
        case (.declined, _):
            return Icon.error
        case (.completed, .chargeback),
             (.completed, .refund),
             (.completed, .paymentWithCashback):
            return Icon.arrowDown
        case (.completed, _):
            return Icon.creditcard
        }
    }

    var tag: TagView {
        switch state {
        case .pending, .created:
            return TagView(text: displayStatus, variant: .infoAlt)
        case .cancelled:
            return TagView(text: displayStatus, variant: .default)
        case .declined:
            return TagView(text: displayStatus, variant: .error)
        case .completed:
            return TagView(text: displayStatus, variant: .success)
        }
    }
}

extension FeatureCardIssuingDomain.Money {

    var displayString: String {
        guard let currency = try? CurrencyType(code: symbol),
              let decimal = Decimal(string: value)
        else {
            return ""
        }

        return MoneyValue.create(major: decimal, currency: currency).displayString
    }

    var isZero: Bool {
        guard let decimal = Decimal(string: value) else {
            return true
        }

        return decimal.isZero || decimal.isNaN
    }
}
