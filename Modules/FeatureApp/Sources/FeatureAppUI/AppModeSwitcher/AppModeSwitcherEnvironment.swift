import AnalyticsKit
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureBackupRecoveryPhraseUI
import MoneyKit
import PlatformKit

public struct AppModeSwitcherEnvironment {
    public let app: AppProtocol
    public let recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding
    public let backupFundsRouter: RecoveryPhraseBackupRouterAPI
    public let analyticsRecorder: AnalyticsEventRecorderAPI

    public init(
        app: AppProtocol,
        recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding,
        backupFundsRouter: RecoveryPhraseBackupRouterAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.app = app
        self.recoveryPhraseStatusProviding = recoveryPhraseStatusProviding
        self.backupFundsRouter = backupFundsRouter
        self.analyticsRecorder = analyticsRecorder
    }
}
