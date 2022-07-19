import AnalyticsKit
@_exported import BlockchainNamespace
import DIKit
import ErrorsUI
import FeatureAppUI
import FeatureAttributionDomain
import FeatureCoinUI
import FeatureCustomerSupportUI
import FeatureReferralDomain
import FeatureReferralUI
import FirebaseCore
import FirebaseInstallations
import FirebaseProtocol
import FirebaseRemoteConfig
import FraudIntelligence
import ObservabilityKit
import ToolKit
import UIKit

let app: AppProtocol = App(
    remoteConfiguration: Session.RemoteConfiguration(
        remote: FirebaseRemoteConfig.RemoteConfig.remoteConfig(),
        default: [
            blockchain.app.configuration.apple.pay.is.enabled: false,
            blockchain.app.configuration.card.issuing.is.enabled: false,
            blockchain.app.configuration.customer.support.is.enabled: BuildFlag.isAlpha,
            blockchain.app.configuration.frequent.action: blockchain.app.configuration.frequent.action.json(in: .main),
            blockchain.app.configuration.manual.login.is.enabled: BuildFlag.isInternal,
            blockchain.app.configuration.native.wallet.payload.is.enabled: false,
            blockchain.app.configuration.redesign.checkout.is.enabled: false,
            blockchain.app.configuration.request.console.logging: false,
            blockchain.app.configuration.SSL.pinning.is.enabled: true,
            blockchain.app.configuration.stx.airdrop.users.is.enabled: false,
            blockchain.app.configuration.stx.all.users.is.enabled: false,
            blockchain.app.configuration.tabs: blockchain.app.configuration.tabs.json(in: .main),
            blockchain.app.configuration.unified.sign_in.is.enabled: false
        ]
    )
)

extension AppProtocol {

    func bootstrap(
        analytics recorder: AnalyticsEventRecorderAPI = resolve(),
        deepLink: DeepLinkCoordinator = resolve(),
        referralService: ReferralServiceAPI = resolve(),
        attributionService: AttributionServiceAPI = resolve(),
        performanceTracing: PerformanceTracingServiceAPI = resolve(),
        featureFlagService: FeatureFlagsServiceAPI = resolve()
    ) {

        state.transaction { state in
            state.set(blockchain.app.deep_link.dsl.is.enabled, to: BuildFlag.isInternal)
        }

        observers.insert(KYCExtraQuestionsObserver(app: self))
        observers.insert(NabuUserSessionObserver(app: self))
        observers.insert(CoinViewAnalyticsObserver(app: self, analytics: recorder))
        observers.insert(CoinViewObserver(app: self))
        observers.insert(ReferralAppObserver(
            app: self,
            referralService: referralService,
            featureFlagService: featureFlagService
        ))
        observers.insert(AttributionAppObserver(app: self, attributionService: attributionService))
        observers.insert(deepLink)
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        observers.insert(PulseBlockchainNamespaceEventLogger(app: self))
        #endif
        observers.insert(ErrorActionObserver(app: self, application: UIApplication.shared))
        observers.insert(RootViewAnalyticsObserver(self, analytics: recorder))
        observers.insert(PerformanceTracingObserver(app: self, service: performanceTracing))

        let intercom = (
            apiKey: Bundle.main.plist.intercomAPIKey[] as String?,
            appId: Bundle.main.plist.intercomAppId[] as String?
        )

        if let apiKey = intercom.apiKey, let appId = intercom.appId {
            observers.insert(
                CustomerSupportObserver<Intercom>(
                    app: self,
                    apiKey: apiKey,
                    appId: appId,
                    open: UIApplication.shared.open,
                    unreadNotificationName: NSNotification.Name.IntercomUnreadConversationCountDidChange
                )
            )
        }

        Task {
            let result = try await Installations.installations().authTokenForcingRefresh(true)
            state.transaction { state in
                state.set(blockchain.user.token.firebase.installation, to: result.authToken)
            }
        }
    }
}

extension FirebaseRemoteConfig.RemoteConfig: RemoteConfiguration_p {}
extension FirebaseRemoteConfig.RemoteConfigValue: RemoteConfigurationValue_p {}
extension FirebaseRemoteConfig.RemoteConfigFetchStatus: RemoteConfigurationFetchStatus_p {}
extension FirebaseRemoteConfig.RemoteConfigSource: RemoteConfigurationSource_p {}

#if canImport(MobileIntelligence)
import class MobileIntelligence.MobileIntelligence
import struct MobileIntelligence.Options
import struct MobileIntelligence.Response
import struct MobileIntelligence.UpdateOptions

extension MobileIntelligence: MobileIntelligence_p {

    public static func start(_ options: Options) {
        MobileIntelligence(withOptions: options)
    }
}

extension Options: MobileIntelligenceOptions_p {}
extension Response: MobileIntelligenceResponse_p {}
extension UpdateOptions: MobileIntelligenceUpdateOptions_p {}

#endif

#if canImport(Intercom)
import class Intercom.ICMUserAttributes
import class Intercom.Intercom
extension Intercom: Intercom_p {}
extension ICMUserAttributes: IntercomUserAttributes_p {}
#endif

extension Tag.Event {

    fileprivate func json(in bundle: Bundle) -> Any? {
        guard let path = Bundle.main.path(forResource: description, ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    }
}
