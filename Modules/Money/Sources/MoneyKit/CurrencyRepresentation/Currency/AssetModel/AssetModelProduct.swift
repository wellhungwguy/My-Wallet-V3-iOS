// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A product of an `AssetModel`.
public enum AssetModelProduct: String, Hashable, CaseIterable {

    case privateKey = "PrivateKey"

    case mercuryDeposits = "MercuryDeposits"

    case mercuryWithdrawals = "MercuryWithdrawals"

    case interestBalance = "InterestBalance"

    case custodialWalletBalance = "CustodialWalletBalance"

    /// Whether the current `AssetModelProduct` causes its owner currency to be enabled in the wallet app.
    fileprivate var enablesCurrency: Bool {
        switch self {
        case .custodialWalletBalance:
            return true
        default:
            return false
        }
    }
}

extension Array where Element == AssetModelProduct {

    /// Whether the list of supported products causes its owner currency to be enabled in the wallet app.
    var enablesCurrency: Bool {
        contains { product in
            product.enablesCurrency
        }
    }
}
