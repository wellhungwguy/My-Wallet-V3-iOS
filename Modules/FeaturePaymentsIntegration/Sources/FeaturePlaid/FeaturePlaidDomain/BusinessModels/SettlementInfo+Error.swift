// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Localization

typealias LocalizedString = LocalizationConstants.Transaction.Confirmation

extension SettlementReasonType {
    public func uxError(_ accountId: String? = nil) -> UX.Error {
        switch self {
        case .requiresUpdate:
            guard let accountId = accountId else {
                return SettlementReasonType.generic.uxError()
            }

            let link = PlaidURLFactory.startPlaidUpdating(accountId)
            guard let url = URL(string: link ?? "invalid link will error") else {
                return SettlementReasonType.generic.uxError()
            }

            let update = UX.Action(
                title: LocalizedString.Error.RequiresUpdate.relinkBankActionTitle,
                url: url
            )
            return UX.Error(
                title: LocalizedString.Error.RequiresUpdate.title,
                message: LocalizedString.Error.RequiresUpdate.message,
                actions: [update]
            )
        case .insufficientBalance:
            return UX.Error(
                title: LocalizedString.Error.InsufficientFunds.title,
                message: LocalizedString.Error.InsufficientFunds.message
            )
        case .staleBalance:
            return UX.Error(
                title: LocalizedString.Error.StaleBalance.title,
                message: LocalizedString.Error.StaleBalance.message
            )

        default:
            return UX.Error(
                title: LocalizedString.Error.GenericOops.title,
                message: LocalizedString.Error.GenericOops.message
            )
        }
    }
}
