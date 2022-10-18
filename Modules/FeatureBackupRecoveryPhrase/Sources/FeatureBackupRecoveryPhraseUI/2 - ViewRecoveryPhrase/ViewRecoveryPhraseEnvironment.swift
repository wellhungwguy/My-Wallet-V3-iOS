import BlockchainNamespace
import ComposableArchitecture
import DIKit
import FeatureBackupRecoveryPhraseDomain
import Foundation
import PlatformKit

public struct ViewRecoveryPhraseEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let onNext: () -> Void
    public let onDone: () -> Void
    public let onFailed: () -> Void
    public let onIcloudBackedUp: () -> Void
    public let recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI
    public let recoveryPhraseRepository: RecoveryPhraseRepositoryAPI
    public let cloudBackupService: CloudBackupConfiguring

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        recoveryPhraseRepository: RecoveryPhraseRepositoryAPI,
        recoveryPhraseService: RecoveryPhraseVerifyingServiceAPI,
        cloudBackupService: CloudBackupConfiguring,
        onNext: @escaping () -> Void,
        onDone: @escaping () -> Void,
        onFailed: @escaping () -> Void,
        onIcloudBackedUp: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.cloudBackupService = cloudBackupService
        recoveryPhraseVerifyingService = recoveryPhraseService
        self.recoveryPhraseRepository = recoveryPhraseRepository
        self.onNext = onNext
        self.onDone = onDone
        self.onFailed = onFailed
        self.onIcloudBackedUp = onIcloudBackedUp
    }
}
