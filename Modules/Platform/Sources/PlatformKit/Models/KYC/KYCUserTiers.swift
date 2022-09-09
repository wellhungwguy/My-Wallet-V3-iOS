// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension KYC {
    public struct UserTiers: Decodable, Equatable {
        public let tiers: [KYC.UserTier]

        public var isTier0: Bool {
            latestApprovedTier == .tier0
        }

        /// `true` if tier 2 is in manual review or pending
        public var isTier2Pending: Bool {
            tierAccountStatus(for: .tier2) == .underReview || tierAccountStatus(for: .tier2) == .pending
        }

        /// `true` in case the user has a verified GOLD tier.
        public var isTier2Approved: Bool {
            tierAccountStatus(for: .tier2) == .approved
        }

        public var isTier1Approved: Bool {
            tierAccountStatus(for: .tier1) == .approved
        }

        public init(tiers: [KYC.UserTier]) {
            self.tiers = tiers
        }

        /// Returns the KYC.AccountStatus for the given KYC.Tier
        public func tierAccountStatus(for tier: KYC.Tier) -> KYC.AccountStatus {
            tiers
                .first(where: { $0.tier == tier })
                .map(\.state.accountStatus) ?? .none
        }

        /// Returns the latest tier, approved OR in progress (pending || in-review)
        public var latestTier: KYC.Tier {
            guard tierAccountStatus(for: .tier1).isInProgressOrApproved else {
                return .tier0
            }
            guard tierAccountStatus(for: .tier2).isInProgressOrApproved else {
                return .tier1
            }
            return .tier2
        }

        /// Returns the latest approved tier
        public var latestApprovedTier: KYC.Tier {
            guard tierAccountStatus(for: .tier1).isApproved else {
                return .tier0
            }
            guard tierAccountStatus(for: .tier2).isApproved else {
                return .tier1
            }
            return .tier2
        }

        /// Returns `true` if the user is not tier2 verified, rejected or pending
        public var canCompleteTier2: Bool {
            tiers.contains(where: {
                $0.tier == .tier2 &&
                    ($0.state != .pending && $0.state != .rejected && $0.state != .verified)
            })
        }
    }
}

extension KYC.UserTiers {

    public func canRequestSDDPaymentMethods(isSDDEligible: Bool) -> Bool {
        latestApprovedTier < .tier2 && isSDDEligible
    }

    public func canPurchaseCrypto(isSDDVerified: Bool) -> Bool {
        isTier2Approved || (latestApprovedTier == .tier1 && isSDDVerified)
    }
}

extension KYC.Tier.State {
    fileprivate var accountStatus: KYC.AccountStatus {
        switch self {
        case .none:
            return .none
        case .rejected:
            return .failed
        case .pending:
            return .pending
        case .verified:
            return .approved
        case .under_review:
            return .underReview
        }
    }
}
