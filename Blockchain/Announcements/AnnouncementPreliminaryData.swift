// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationDomain
import FeatureProductsDomain
import MoneyKit
import PlatformKit
import WalletPayloadKit

/// Contains any needed remotely fetched data before displaying announcements.
struct AnnouncementPreliminaryData {

    // MARK: Types

    struct AssetRename {
        let asset: CryptoCurrency
        let oldTicker: String
        let balance: MoneyValue
    }

    struct SimpleBuy {
        let hasLinkedBanks: Bool
        let isAvailable: Bool
        let isEligible: Bool
        let pendingOrderDetails: [OrderDetails]
    }

    // MARK: Properties

    /// User is able to claim free Blockchain.com domain.
    let claimFreeDomainEligible: Bool

    /// Announcement New Asset
    let newAsset: CryptoCurrency?

    /// Announcement Asset Rename
    let assetRename: AssetRename?

    /// The nabu user
    let user: NabuUser

    /// User tiers information
    let tiers: KYC.UserTiers

    /// User Simplified Due Diligence Eligibility
    let isSDDEligible: Bool

    let country: CountryData?

    /// The authentication type (2FA / standard)
    let authenticatorType: WalletAuthenticatorType

    var isKycSupported: Bool {
        country?.isKycSupported ?? false
    }

    var hasTwoFA: Bool {
        authenticatorType != .standard
    }

    let simpleBuy: SimpleBuy

    var hasIncompleteBuyFlow: Bool {
        simpleBuyEventCache[.hasShownBuyScreen] && simpleBuy.isAvailable
    }

    /// Whether the user has a wallet balance in any account.
    let hasAnyWalletBalance: Bool

    let majorProductBlocked: ProductIneligibility?

    private let simpleBuyEventCache: EventCache

    init(
        assetRename: AssetRename?,
        authenticatorType: WalletAuthenticatorType,
        claimFreeDomainEligible: Bool,
        countries: [CountryData],
        majorProductBlocked: ProductIneligibility?,
        hasAnyWalletBalance: Bool,
        isSDDEligible: Bool,
        newAsset: CryptoCurrency?,
        simpleBuy: SimpleBuy,
        simpleBuyEventCache: EventCache = resolve(),
        tiers: KYC.UserTiers,
        user: NabuUser
    ) {
        self.assetRename = assetRename
        self.authenticatorType = authenticatorType
        self.claimFreeDomainEligible = claimFreeDomainEligible
        self.hasAnyWalletBalance = hasAnyWalletBalance
        self.isSDDEligible = isSDDEligible
        self.majorProductBlocked = majorProductBlocked
        self.newAsset = newAsset
        self.simpleBuy = simpleBuy
        self.simpleBuyEventCache = simpleBuyEventCache
        self.tiers = tiers
        self.user = user
        country = countries.first { $0.code == user.address?.countryCode }
    }
}
