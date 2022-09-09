// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import ToolKit

class KYCSettings: KYCSettingsAPI {

    private let cacheSuite: CacheSuite

    init(cacheSuite: CacheSuite = resolve()) {
        self.cacheSuite = cacheSuite
    }

    /**
     Determines if the user is currently completing the KYC process. This allow the application to determine
     if it should show the *Continue verification* announcement card on the dashboard.

     - Note:
     This value is set to `true` whenever the user taps on the primary button on the KYC welcome screen.

     This value is set to `false` whenever the *Application complete* screen in the KYC flow will disappear.

     - Important:
     This setting **MUST** be set to `false` upon logging the user out of the application.
     */
    var isCompletingKyc: Bool {
        get {
            cacheSuite.bool(forKey: UserDefaults.KYC.Keys.isCompletingKyc.rawValue)
        }
        set {
            cacheSuite.set(newValue, forKey: UserDefaults.KYC.Keys.isCompletingKyc.rawValue)
        }
    }

    var latestKycPage: KYCPageType? {
        get {
            let page = cacheSuite.integer(forKey: UserDefaults.KYC.Keys.kycLatestPage.rawValue)
            return KYCPageType(rawValue: page)
        }
        set {
            if newValue == nil {
                cacheSuite.set(nil, forKey: UserDefaults.KYC.Keys.kycLatestPage.rawValue)
                return
            }

            let previousPage = cacheSuite.integer(forKey: UserDefaults.KYC.Keys.kycLatestPage.rawValue)
            guard let newPage = newValue else {
                Logger.shared.warning("\(newValue?.rawValue ?? 0) is not less than \(previousPage) for 'latestKycPage'.")
                return
            }
            cacheSuite.set(newPage.rawValue, forKey: UserDefaults.KYC.Keys.kycLatestPage.rawValue)
        }
    }

    /// Determines if the user deep linked into the app using an email verification link. This
    /// value is used to continue KYC'ing at the Verify Email step.
    var didTapOnKycDeepLink: Bool {
        get {
            cacheSuite.bool(forKey: UserDefaults.KYC.Keys.didTapOnKycDeepLink.rawValue)
        }
        set {
            cacheSuite.set(newValue, forKey: UserDefaults.KYC.Keys.didTapOnKycDeepLink.rawValue)
        }
    }

    /// Determines if the user deep linked into the app using a document resubmission link. This
    /// value is used to continue KYC'ing at the Verify Your Identity step.
    var didTapOnDocumentResubmissionDeepLink: Bool {
        get {
            cacheSuite.bool(forKey: UserDefaults.KYC.Keys.didTapOnDocumentResubmissionDeepLink.rawValue)
        }
        set {
            cacheSuite.set(newValue, forKey: UserDefaults.KYC.Keys.didTapOnDocumentResubmissionDeepLink.rawValue)
        }
    }

    /// Property saved from parsing '' query param from document resubmission deeplink.
    /// Used to pass reasons for initial verification failure to display in the Verify Your
    /// Identity screen
    var documentResubmissionLinkReason: String? {
        get {
            cacheSuite.string(forKey: UserDefaults.KYC.Keys.documentResubmissionLinkReason.rawValue)
        }
        set {
            cacheSuite.set(newValue, forKey: UserDefaults.KYC.Keys.documentResubmissionLinkReason.rawValue)
        }
    }

    func reset() {
        latestKycPage = nil
        isCompletingKyc = false
        didTapOnKycDeepLink = false
        didTapOnDocumentResubmissionDeepLink = false
        documentResubmissionLinkReason = nil
    }
}

extension UserDefaults {

    enum KYC {
        enum Keys: String {
            case didTapOnKycDeepLink
            case isCompletingKyc = "shouldShowKYCAnnouncementCard"
            case kycLatestPage
            case didTapOnDocumentResubmissionDeepLink
            case documentResubmissionLinkReason
        }
    }
}
