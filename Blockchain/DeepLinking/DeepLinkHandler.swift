// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import FeatureAppUI
import FeatureKYCDomain
import FeatureOpenBankingDomain
import FeatureSettingsDomain
import FirebaseAnalytics
import FirebaseDynamicLinks
import PlatformKit
import ToolKit

final class DeepLinkHandler: DeepLinkHandling {

    private let kycSettings: KYCSettingsAPI
    private let app: AppProtocol

    init(
        kycSettings: KYCSettingsAPI = resolve(),
        app: AppProtocol = resolve()
    ) {
        self.kycSettings = kycSettings
        self.app = app
    }

    func handle(
        deepLink: String,
        supportedRoutes: [DeepLinkRoute] = DeepLinkRoute.allCases
    ) {
        Logger.shared.debug("[DeepLinkHandler] Attempting to handle deep link.")
        guard let route = DeepLinkRoute.route(from: deepLink, supportedRoutes: supportedRoutes),
              let payload = DeepLinkPayload.create(from: deepLink, supportedRoutes: supportedRoutes)
        else {
            Logger.shared.debug("Unhandled deep link \(deepLink)")
            return
        }
        Logger.shared.debug("[DeepLinkHandler] Handling deep link \(deepLink) on route \(route)")
        switch route {
        case .kyc,
             .kycVerifyEmail:
            handleKyc()
        case .kycDocumentResubmission:
            handleKycDocumentResubmission(payload.params)
        case .openBankingLink, .openBankingApprove:
            handleOpenBanking(payload.params)
        }
    }

    private func handleKycDocumentResubmission(_ params: [String: String]) {
        kycSettings.didTapOnDocumentResubmissionDeepLink = true
        kycSettings.documentResubmissionLinkReason = params[DeepLinkConstant.documentResubmissionReason]
    }

    private func handleKyc() {
        kycSettings.didTapOnKycDeepLink = true
    }

    /// # Examples
    ///
    /// success: ?one-time-token=...#/open/ob-bank-link
    ///          ?callbackUrl=nabu-gateway/payments/banktransfer/one-time-token
    ///
    /// failure: ?callbackUrl=nabu-gateway%2Fpayments%2Fbanktransfer%2Fone-time-token
    ///          &application-user-id=beneficiary%3A95e826e7-fb58-4020-8815-c4c2839fe8bc
    ///          &user-uuid=c69af99b-291b-4bd9-85af-099a1b948442
    ///          &institution=monzo_ob
    ///          &error=uncategorized_error
    ///          &error-source=institution
    ///          &error-description=VGhpcyByZXF1ZXN0IGhhcyBhbHJlYWR5IGJlZW4gYXV0aG9yaXNlZA%3D%3D
    private func handleOpenBanking(_ params: [String: String]) {
        app.state.transaction { state in
            if let token = params["one-time-token"] {
                state.set(blockchain.ux.payment.method.open.banking.consent.token, to: token)
            }
            if let error = params["error"] {
                state.set(blockchain.ux.payment.method.open.banking.consent.error, to: OpenBanking.Error.code(error))
            }
        }
    }
}

// MARK: DynamicLinksAPI

extension FirebaseDynamicLinks.DynamicLink: DynamicLinkAPI {}

extension FirebaseDynamicLinks.DynamicLinks: DynamicLinksAPI {
    public func handleUniversalLink(url: URL, _ completion: @escaping (DynamicLinkAPI?, Error?) -> Void) -> Bool {
        handleUniversalLink(url) { dynamicLink, error in
            completion(dynamicLink, error)
        }
    }

    public func canHandle(url: URL) -> Bool {
        // Firebase doesn't provide a good way to check if the given url can be handled
        // The deprecated method is the best way to check that a URL is part of DynamicLink from Firebase
        dynamicLink(fromUniversalLink: url) != nil || matchesShortLinkFormat(url)
    }
}
