// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import ERC20Kit
import FeatureAppDomain
import FeatureAttributionDomain
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import FeatureCardPaymentDomain
import FeatureDebugUI
import FeatureOpenBankingDomain
import FeatureSettingsDomain
import NetworkKit
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import WalletPayloadKit

public struct AppEnvironment {
    var accountRecoveryService: AccountRecoveryServiceAPI
    var alertViewPresenter: AlertViewPresenterAPI
    var analyticsRecorder: AnalyticsEventRecorderAPI
    var app: AppProtocol
    var appStoreOpener: AppStoreOpening
    var backgroundAppHandler: BackgroundAppHandlerAPI
    var blockchainSettings: BlockchainSettings.App
    var blurEffectHandler: BlurVisualEffectHandlerAPI
    var buildVersionProvider: () -> String
    var cacheSuite: CacheSuite
    var cardService: CardServiceAPI
    var certificatePinner: CertificatePinnerAPI
    var coincore: CoincoreAPI
    var crashlyticsRecorder: Recording
    var credentialsStore: CredentialsStoreAPI
    var deeplinkAppHandler: AppDeeplinkHandlerAPI
    var deeplinkHandler: DeepLinkHandling
    var deeplinkRouter: DeepLinkRouting
    var delegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceAPI
    var deviceInfo: DeviceInfo
    var deviceVerificationService: DeviceVerificationServiceAPI
    var erc20CryptoAssetService: ERC20CryptoAssetServiceAPI
    var exchangeRepository: ExchangeAccountRepositoryAPI
    var externalAppOpener: ExternalAppOpener
    var featureFlagsService: FeatureFlagsServiceAPI
    var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    var forgetWalletService: ForgetWalletService
    var loadingViewPresenter: LoadingViewPresenting
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var mobileAuthSyncService: MobileAuthSyncServiceAPI
    var nabuUserService: NabuUserServiceAPI
    var observabilityService: ObservabilityServiceAPI
    var openBanking: OpenBanking
    var performanceTracing: PerformanceTracingServiceAPI
    var pushNotificationsRepository: PushNotificationsRepositoryAPI
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var resetPasswordService: ResetPasswordServiceAPI
    var secondPasswordPrompter: SecondPasswordPromptable
    var sharedContainer: SharedContainerUserDefaults
    var siftService: FeatureAuthenticationDomain.SiftServiceAPI
    var supportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI
    var urlSession: URLSession
    var walletManager: WalletManagerAPI
    var walletPayloadService: WalletPayloadServiceAPI
    var walletRepoPersistence: WalletRepoPersistenceAPI
    var walletService: WalletService
    var walletStateProvider: WalletStateProvider
    var walletUpgradeService: WalletUpgradeServicing

    public init(
        accountRecoveryService: AccountRecoveryServiceAPI,
        alertViewPresenter: AlertViewPresenterAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        app: AppProtocol,
        appStoreOpener: AppStoreOpening,
        backgroundAppHandler: BackgroundAppHandlerAPI,
        blockchainSettings: BlockchainSettings.App,
        blurEffectHandler: BlurVisualEffectHandlerAPI,
        buildVersionProvider: @escaping () -> String,
        cacheSuite: CacheSuite,
        cardService: CardServiceAPI,
        certificatePinner: CertificatePinnerAPI,
        coincore: CoincoreAPI,
        crashlyticsRecorder: Recording,
        credentialsStore: CredentialsStoreAPI,
        deeplinkAppHandler: AppDeeplinkHandlerAPI,
        deeplinkHandler: DeepLinkHandling,
        deeplinkRouter: DeepLinkRouting,
        delegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceAPI,
        deviceInfo: DeviceInfo,
        deviceVerificationService: DeviceVerificationServiceAPI,
        erc20CryptoAssetService: ERC20CryptoAssetServiceAPI,
        exchangeRepository: ExchangeAccountRepositoryAPI,
        externalAppOpener: ExternalAppOpener,
        featureFlagsService: FeatureFlagsServiceAPI,
        fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI,
        forgetWalletService: ForgetWalletService,
        loadingViewPresenter: LoadingViewPresenting,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        mobileAuthSyncService: MobileAuthSyncServiceAPI,
        nabuUserService: NabuUserServiceAPI,
        observabilityService: ObservabilityServiceAPI,
        openBanking: OpenBanking,
        performanceTracing: PerformanceTracingServiceAPI,
        pushNotificationsRepository: PushNotificationsRepositoryAPI,
        remoteNotificationServiceContainer: RemoteNotificationServiceContaining,
        resetPasswordService: ResetPasswordServiceAPI,
        secondPasswordPrompter: SecondPasswordPromptable,
        sharedContainer: SharedContainerUserDefaults,
        siftService: FeatureAuthenticationDomain.SiftServiceAPI,
        supportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI,
        urlSession: URLSession,
        walletManager: WalletManagerAPI,
        walletPayloadService: WalletPayloadServiceAPI,
        walletRepoPersistence: WalletRepoPersistenceAPI,
        walletService: WalletService,
        walletStateProvider: WalletStateProvider,
        walletUpgradeService: WalletUpgradeServicing
    ) {
        self.accountRecoveryService = accountRecoveryService
        self.alertViewPresenter = alertViewPresenter
        self.analyticsRecorder = analyticsRecorder
        self.app = app
        self.appStoreOpener = appStoreOpener
        self.backgroundAppHandler = backgroundAppHandler
        self.blockchainSettings = blockchainSettings
        self.blurEffectHandler = blurEffectHandler
        self.buildVersionProvider = buildVersionProvider
        self.cacheSuite = cacheSuite
        self.cardService = cardService
        self.certificatePinner = certificatePinner
        self.coincore = coincore
        self.crashlyticsRecorder = crashlyticsRecorder
        self.credentialsStore = credentialsStore
        self.deeplinkAppHandler = deeplinkAppHandler
        self.deeplinkHandler = deeplinkHandler
        self.deeplinkRouter = deeplinkRouter
        self.delegatedCustodySubscriptionsService = delegatedCustodySubscriptionsService
        self.deviceInfo = deviceInfo
        self.deviceVerificationService = deviceVerificationService
        self.erc20CryptoAssetService = erc20CryptoAssetService
        self.exchangeRepository = exchangeRepository
        self.externalAppOpener = externalAppOpener
        self.featureFlagsService = featureFlagsService
        self.fiatCurrencySettingsService = fiatCurrencySettingsService
        self.forgetWalletService = forgetWalletService
        self.loadingViewPresenter = loadingViewPresenter
        self.mainQueue = mainQueue
        self.mobileAuthSyncService = mobileAuthSyncService
        self.nabuUserService = nabuUserService
        self.observabilityService = observabilityService
        self.openBanking = openBanking
        self.performanceTracing = performanceTracing
        self.pushNotificationsRepository = pushNotificationsRepository
        self.remoteNotificationServiceContainer = remoteNotificationServiceContainer
        self.resetPasswordService = resetPasswordService
        self.secondPasswordPrompter = secondPasswordPrompter
        self.sharedContainer = sharedContainer
        self.siftService = siftService
        self.supportedAssetsRemoteService = supportedAssetsRemoteService
        self.urlSession = urlSession
        self.walletManager = walletManager
        self.walletPayloadService = walletPayloadService
        self.walletRepoPersistence = walletRepoPersistence
        self.walletService = walletService
        self.walletStateProvider = walletStateProvider
        self.walletUpgradeService = walletUpgradeService
    }
}
