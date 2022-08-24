import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureSettingsUI
import MoneyKit
import PlatformKit

public struct AppModeSwitcherEnvironment {
    public let app: AppProtocol
    public let recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding
    public let backupFundsRouter: BackupFundsRouterAPI

    public init(
        app: AppProtocol,
        recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding,
        backupFundsRouter: BackupFundsRouterAPI
    ) {
        self.app = app
        self.recoveryPhraseStatusProviding = recoveryPhraseStatusProviding
        self.backupFundsRouter = backupFundsRouter
    }
}
