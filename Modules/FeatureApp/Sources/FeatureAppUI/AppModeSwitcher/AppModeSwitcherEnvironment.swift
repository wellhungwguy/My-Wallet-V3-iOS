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

    public var backupRouterAPI = BackupFundsRouter(
        entry: .defiIntroScreen,
        navigationRouter: resolve()
    )
    public init(
        app: AppProtocol,
        recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding
    ) {
        self.app = app
        self.recoveryPhraseStatusProviding = recoveryPhraseStatusProviding
    }
}
