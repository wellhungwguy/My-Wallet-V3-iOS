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
import FeatureUserTagSyncDomain
import FirebaseCore
import FirebaseInstallations
import FirebaseProtocol
import FirebaseRemoteConfig
import FraudIntelligence
import ObservabilityKit
import ToolKit
import UIKit

let app: AppProtocol = try! App(
    remoteConfiguration: Session.RemoteConfiguration(
        remote: FirebaseRemoteConfig.RemoteConfig.remoteConfig(),
        default: .init(blockchain.app.configuration.json(in: .main) as Any) + [
            blockchain.app.configuration.manual.login.is.enabled: BuildFlag.isInternal
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
        featureFlagService: FeatureFlagsServiceAPI = resolve(),
        userTagService: UserTagServiceAPI = resolve()
    ) {
        observers.insert(ApplicationStateObserver(app: self))
        observers.insert(AppHapticObserver(app: self))
        observers.insert(AppAnalyticsObserver(app: self))
        observers.insert(resolve() as AppAnalyticsTraitRepository)
        observers.insert(KYCExtraQuestionsObserver(app: self))
        observers.insert(NabuUserSessionObserver(app: self))
        observers.insert(CoinViewAnalyticsObserver(app: self, analytics: recorder))
        observers.insert(CoinViewObserver(app: self))
        observers.insert(ReferralAppObserver(app: self, referralService: referralService))
        observers.insert(AttributionAppObserver(app: self, attributionService: attributionService))
        observers.insert(UserTagObserver(app: self, userTagSyncService: userTagService))
        observers.insert(SuperAppIntroObserver(app: self))
        observers.insert(EmbraceObserver(app: self))
        observers.insert(GenerateSession(app: self))
        observers.insert(PlaidLinkObserver(app: self))
        // observers.insert(EmbraceObserver(app: self))
        observers.insert(deepLink)
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        observers.insert(PulseBlockchainNamespaceEventLogger(app: self))
        observers.insert(MultiAppViewDebuggingObserver(app: self))
        #endif
        observers.insert(ActionObserver(app: self, application: UIApplication.shared))
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

        #if canImport(MobileIntelligence)
        observers.insert(Sardine<MobileIntelligence>(self))
        #endif

        Task {
            let result = try await Installations.installations().authTokenForcingRefresh(true)
            state.transaction { state in
                state.set(blockchain.user.token.firebase.installation, to: result.authToken)
            }
        }

        if state.doesNotContain(blockchain.ux.user.account.preferences.small.balances.are.hidden) {
            state.set(blockchain.ux.user.account.preferences.small.balances.are.hidden, to: true)
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
