import ComposableArchitecture
import FeatureBackupRecoveryPhraseDomain
import Foundation

public struct ManualBackupSeedPhraseEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let onNext: () -> Void
    public let recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        onNext: @escaping () -> Void,
        recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.onNext = onNext
        self.recoveryPhraseVerifyingService = recoveryPhraseVerifyingService
    }
}
