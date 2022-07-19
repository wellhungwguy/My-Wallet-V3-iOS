// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import Errors
import FeatureFormDomain
import PlatformKit
import RxSwift

public final class KYCPager: KYCPagerAPI {

    private let app: AppProtocol
    private let nabuUserService: NabuUserServiceAPI
    public private(set) var tier: KYC.Tier
    public private(set) var tiersResponse: KYC.UserTiers

    public init(
        app: AppProtocol = resolve(),
        nabuUserService: NabuUserServiceAPI = resolve(),
        tier: KYC.Tier,
        tiersResponse: KYC.UserTiers
    ) {
        self.app = app
        self.nabuUserService = nabuUserService
        self.tier = tier
        self.tiersResponse = tiersResponse
    }

    public func nextPage(from page: KYCPageType, payload: KYCPagePayload?) -> Maybe<KYCPageType> {
        // Get country from payload if present
        var kycCountry: CountryData?
        if let payload = payload {
            switch payload {
            case .countrySelected(let country):
                kycCountry = country
            case .sddVerification(let isVerified):
                do {
                    guard try app.state.get(blockchain.ux.kyc.extra.questions.form.is.empty) else {
                        return .just(.accountUsageForm)
                    }
                } catch { /* ignore */ }
                let shouldCompleteKYC = isVerified && tier < .tier2
                return shouldCompleteKYC ? .empty() : .just(.accountUsageForm)
            case .stateSelected:
                // no-op: handled in coordinator
                break
            case .phoneNumberUpdated,
                 .emailPendingVerification,
                 .accountStatus:
                // Not handled here
                break
            }
        }
        return nabuUserService.user.asSingle()
            .flatMapMaybe { [weak self] user -> Maybe<KYCPageType> in
                guard let strongSelf = self else {
                    return Maybe.empty()
                }
                guard let nextPage = page.nextPage(
                    forTier: strongSelf.tier,
                    user: user,
                    country: kycCountry,
                    tiersResponse: strongSelf.tiersResponse
                ) else {
                    return strongSelf.nextPageFromNextTierMaybe()
                }
                return Maybe.just(nextPage)
            }
    }

    private func nextPageFromNextTierMaybe() -> Maybe<KYCPageType> {
        nabuUserService.fetchUser().asSingle().flatMapMaybe { [weak self] user -> Maybe<KYCPageType> in
            guard let strongSelf = self else {
                return Maybe.empty()
            }
            guard let tiers = user.tiers else {
                return Maybe.empty()
            }

            let nextTier = tiers.next

            // If the next tier is the same as the tier property in KYCPager, this means that the
            // user has already completely the flow for the tier property.
            guard nextTier != strongSelf.tier else {
                return Maybe.empty()
            }

            guard nextTier.rawValue > tiers.selected.rawValue else {
                return Maybe.empty()
            }

            guard let moreInfoPage = KYCPageType.moreInfoPage(forTier: nextTier) else {
                return Maybe.empty()
            }

            // If all guard checks pass, this means that we have determined that the user should be
            // forced to KYC on the next tier
            strongSelf.tier = nextTier

            return Maybe.just(moreInfoPage)
        }
    }
}

// MARK: KYCPageType Extensions

extension KYCPageType {

    public static func startingPage(
        forUser user: NabuUser,
        requiredTier: KYC.Tier,
        tiersResponse: KYC.UserTiers,
        isSDDEligible: Bool,
        isSDDVerified: Bool,
        hasQuestions: Bool
    ) -> KYCPageType {
        guard user.email.verified else {
            return .enterEmail
        }

        guard user.address != nil else {
            return .country
        }

        let countryCode = user.address?.countryCode.lowercased()
        let state = user.address?.state
        if countryCode == "us", state == nil {
            return .states
        }

        guard user.personalDetails.isComplete else {
            return .profile
        }

        guard user.address?.postalCode != nil else {
            return .address
        }

        guard let mobile = user.mobile, mobile.verified else {
            return .enterPhone
        }

        if hasQuestions {
            return .accountUsageForm
        }

        guard tiersResponse.canCompleteTier2 else {
            return .accountStatus
        }

        guard requiredTier < .tier2 else {
            return .accountUsageForm
        }

        return .sddVerificationCheck
    }

    public static func moreInfoPage(forTier tier: KYC.Tier) -> KYCPageType? {
        switch tier {
        case .tier2:
            return .tier1ForcedTier2
        default:
            return nil
        }
    }

    public func nextPage(
        forTier tier: KYC.Tier,
        user: NabuUser?,
        country: CountryData?,
        tiersResponse: KYC.UserTiers
    ) -> KYCPageType? {
        switch tier {
        case .tier0,
             .tier1:
            return nextPageTier1(user: user, country: country, requiredTier: tier, tiersResponse: tiersResponse)
        case .tier2:
            return nextPageTier2(user: user, country: country, tiersResponse: tiersResponse)
        }
    }

    private func nextPageTier1(
        user: NabuUser?,
        country: CountryData?,
        requiredTier: KYC.Tier,
        tiersResponse: KYC.UserTiers
    ) -> KYCPageType? {
        switch self {
        case .welcome:
            if let user = user {
                // We can pass true here, as non-eligible users would get send to the Tier 2 upgrade path anyway
                return KYCPageType.startingPage(
                    forUser: user,
                    requiredTier: requiredTier,
                    tiersResponse: tiersResponse,
                    isSDDEligible: true,
                    isSDDVerified: false,
                    hasQuestions: false
                )
            }
            return .enterEmail
        case .enterEmail:
            return .confirmEmail
        case .confirmEmail:
            guard user?.address?.countryCode != nil else {
                return .country
            }
            guard user?.personalDetails.isComplete == false else {
                return .address
            }
            return .profile
        case .country:
            if let country = country, !country.states.isEmpty {
                return .states
            }
            if let user = user, user.personalDetails.isComplete {
                return .address
            }
            return .profile
        case .states:
            return .profile
        case .profile:
            return .address
        case .address:
            return .sddVerificationCheck
        case .sddVerificationCheck:
            // This check could be also in `case .address` but I'm putting this here to ensure that
            // when the KYC flow is closed the backend has already promoted the user to Tier 3.
            // This way, if we check for for KYC status afterwards, the info for Tier 3 should be guaranteed.
            guard requiredTier < .tier2 else {
                return .tier1ForcedTier2
            }
            // END
            return nil
        case .tier1ForcedTier2,
             .enterPhone,
             .confirmPhone,
             .accountUsageForm,
             .verifyIdentity,
             .resubmitIdentity,
             .applicationComplete,
             .accountStatus:
            // All other pages don't have a next page for tier 1
            return nil
        }
    }

    private func nextPageTier2(user: NabuUser?, country: CountryData?, tiersResponse: KYC.UserTiers) -> KYCPageType? {
        switch self {
        case .tier1ForcedTier2:
            // Skip the enter phone step if the user already has verified their phone number
            if let user = user, let mobile = user.mobile, mobile.verified {
                guard tiersResponse.canCompleteTier2 else {
                    return .accountStatus
                }
                return .accountUsageForm
            }
            return .enterPhone
        case .enterPhone:
            return .confirmPhone
        case .confirmPhone:
            return .accountUsageForm
        case .accountUsageForm:
            return user?.needsDocumentResubmission == nil ? .verifyIdentity : .resubmitIdentity
        case .verifyIdentity,
             .resubmitIdentity:
            return .accountStatus
        case .applicationComplete:
            // Not used
            return nil
        case .accountStatus:
            return nil
        case .welcome,
             .enterEmail,
             .confirmEmail,
             .country,
             .states,
             .address,
             .sddVerificationCheck,
             .profile:
            return nextPageTier1(user: user, country: country, requiredTier: .tier2, tiersResponse: tiersResponse)
        }
    }
}
