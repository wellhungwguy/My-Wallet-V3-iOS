// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

/// The announcement types as defined remotely
public enum AnnouncementType: String, Codable {
    case resubmitDocumentsAfterRecovery = "kyc_recovery_resubmission"
    case sddUsersFirstBuy = "sdd_users_buy"
    case simpleBuyKYCIncomplete = "sb_finish_signup"
    case buyBitcoin = "buy_btc"
    case verifyEmail = "verify_email"
    case transferBitcoin = "transfer_btc"
    case twoFA = "two_fa"
    case backupFunds = "backup_funds"
    case verifyIdentity = "kyc_incomplete"
    case resubmitDocuments = "kyc_resubmit"
    case newSwap = "swap_v2"
    case cloudBackup = "cloud_backup"
    case bitpay
    case viewNFTWaitlist = "view_nft_waitlist"
    case fiatFundsKYC = "fiat_funds_kyc"
    case fiatFundsNoKYC = "fiat_funds_no_kyc"
    case interestFunds = "interest_funds"
    case newAsset = "new_asset"
    case assetRename = "asset_rename"
    case ukEntitySwitch = "uk_entity_switch_2022"
    case claimFreeCryptoDomain = "claim_free_crypto_domain"
    case walletConnect = "wallet_connect"
    case taxCenter = "tax_center_available"
    case applePay = "apple_pay"
    case majorProductBlocked = "major_product_blocked"

    /// The key identifying the announcement in cache
    var key: AnnouncementRecord.Key {
        switch self {
        case .majorProductBlocked:
            return .majorProductBlocked
        case .resubmitDocumentsAfterRecovery:
            return .resubmitDocumentsAfterRecovery
        case .sddUsersFirstBuy:
            return .sddUsersFirstBuy
        case .newSwap:
            return .newSwap
        case .cloudBackup:
            return .cloudBackup
        case .verifyEmail:
            return .verifyEmail
        case .buyBitcoin:
            return .buyBitcoin
        case .transferBitcoin:
            return .transferBitcoin
        case .twoFA:
            return .twoFA
        case .backupFunds:
            return .backupFunds
        case .verifyIdentity:
            return .identityVerification
        case .bitpay:
            return .bitpay
        case .resubmitDocuments:
            return .resubmitDocuments
        case .simpleBuyKYCIncomplete:
            return .simpleBuyKYCIncomplete
        case .fiatFundsKYC:
            return .fiatFundsKYC
        case .fiatFundsNoKYC:
            return .fiatFundsNoKYC
        case .interestFunds:
            return .interestFunds
        case .ukEntitySwitch:
            return .ukEntitySwitch
        case .viewNFTWaitlist:
            return .viewNFTWaitlist
        case .claimFreeCryptoDomain:
            return .claimFreeCryptoDomain
        case .walletConnect:
            return .walletConnect
        case .taxCenter:
            return .taxCenter
        case .newAsset:
            if BuildFlag.isInternal {
                unimplemented("AnnouncementType.newAsset does not have a default key.")
            }
            return .newAsset(code: "")
        case .assetRename:
            if BuildFlag.isInternal {
                unimplemented("AnnouncementType.assetRename does not have a default key.")
            }
            return .assetRename(code: "")
        case .applePay:
            return .applePay
        }
    }
}
