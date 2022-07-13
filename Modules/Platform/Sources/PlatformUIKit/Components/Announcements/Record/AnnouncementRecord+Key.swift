// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

extension AnnouncementRecord {

    /// An key used to register this Announcement history
    /// All keys must be prefixed by `"announcement-"`
    public enum Key {

        // MARK: - Persistent

        case sddUsersFirstBuy
        case walletIntro
        case verifyEmail
        case resubmitDocumentsAfterRecovery
        case simpleBuyKYCIncomplete
        case claimFreeCryptoDomain

        // MARK: - Periodic

        case backupFunds
        case twoFA
        case buyBitcoin
        case transferBitcoin
        case newSwap
        case taxCenter

        // MARK: - One Time

        case identityVerification
        case bitpay
        case resubmitDocuments
        case fiatFundsKYC
        case fiatFundsNoKYC
        case cloudBackup
        case interestFunds
        case viewNFTWaitlist
        case newAsset(code: String)
        case assetRename(code: String)
        case ukEntitySwitch
        case walletConnect
        case applePay
        case majorProductBlocked

        var string: String {
            let prefix = "announcement-"
            let key: String
            switch self {
            case .sddUsersFirstBuy:
                key = "cache-sdd-users-buy"
            case .walletIntro:
                key = "cache-wallet-intro"
            case .verifyEmail:
                key = "cache-email-verification"
            case .resubmitDocumentsAfterRecovery:
                key = "cache-resubmit-documents-after-recovery"
            case .simpleBuyKYCIncomplete:
                key = "simple-buy-kyc-incomplete"
            case .claimFreeCryptoDomain:
                key = "claim-free-crypto-domain"

            // MARK: - Periodic

            case .backupFunds:
                key = "cache-backup-funds"
            case .twoFA:
                key = "cache-2fa"
            case .buyBitcoin:
                key = "cache-buy-btc"
            case .transferBitcoin:
                key = "cache-transfer-btc"
            case .newSwap:
                key = "cache-new-swap"
            case .taxCenter:
                key = "tax-center"

            // MARK: - One Time

            case .viewNFTWaitlist:
                key = "view-nft-waitlist"
            case .identityVerification:
                key = "cache-identity-verification"
            case .bitpay:
                key = "cache-bitpay"
            case .resubmitDocuments:
                key = "cache-resubmit-documents"
            case .fiatFundsKYC:
                key = "cache-fiat-funds-kyc"
            case .fiatFundsNoKYC:
                key = "cache-fiat-funds-no-kyc"
            case .cloudBackup:
                key = "cache-cloud-backup"
            case .interestFunds:
                key = "cache-interest-funds"
            case .newAsset(let code):
                key = "cache-new-asset-\(code)"
            case .assetRename(let code):
                key = "cache-asset-rename-\(code)"
            case .ukEntitySwitch:
                key = "uk-entity-switch-2022"
            case .walletConnect:
                key = "wallet-connect"
            case .applePay:
                key = "apple-pay"
            case .majorProductBlocked:
                key = "cache-major-product-blocked"
            }

            return prefix + key
        }
    }
}
