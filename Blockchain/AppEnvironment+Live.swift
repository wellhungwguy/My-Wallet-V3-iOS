// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureAppUI
import FeatureDebugUI
import PlatformKit
import ToolKit
import WalletPayloadKit

extension AppEnvironment {

    static var live: AppEnvironment {
        AppEnvironment(
            accountRecoveryService: resolve(),
            alertViewPresenter: resolve(),
            analyticsRecorder: resolve(),
            app: resolve(),
            appStoreOpener: resolve(),
            backgroundAppHandler: resolve(),
            blockchainSettings: .shared,
            blurEffectHandler: resolve(),
            buildVersionProvider: Bundle.versionAndBuildNumber,
            cacheSuite: resolve(),
            cardService: resolve(),
            certificatePinner: resolve(),
            coincore: resolve(),
            crashlyticsRecorder: resolve(tag: "CrashlyticsRecorder"),
            credentialsStore: resolve(),
            deeplinkAppHandler: resolve(),
            deeplinkHandler: resolve(),
            deeplinkRouter: resolve(),
            delegatedCustodySubscriptionsService: resolve(),
            deviceInfo: resolve(),
            deviceVerificationService: resolve(),
            erc20CryptoAssetService: resolve(),
            exchangeRepository: ExchangeAccountRepository(),
            externalAppOpener: resolve(),
            featureFlagsService: resolve(),
            fiatCurrencySettingsService: resolve(),
            forgetWalletService: .live(
                forgetWallet: DIKit.resolve()
            ),
            loadingViewPresenter: resolve(),
            mainQueue: .main,
            mobileAuthSyncService: resolve(),
            nabuUserService: resolve(),
            observabilityService: resolve(),
            openBanking: resolve(),
            performanceTracing: resolve(),
            pushNotificationsRepository: resolve(),
            remoteNotificationServiceContainer: resolve(),
            resetPasswordService: resolve(),
            secondPasswordPrompter: resolve(),
            sharedContainer: .default,
            siftService: resolve(),
            supportedAssetsRemoteService: resolve(),
            urlSession: resolve(),
            walletManager: resolve(),
            walletPayloadService: resolve(),
            walletRepoPersistence: resolve(),
            walletService: .live(
                fetcher: DIKit.resolve(),
                recovery: DIKit.resolve()
            ),
            walletStateProvider: .live(
                holder: DIKit.resolve()
            ),
            walletUpgradeService: resolve()
        )
    }
}
