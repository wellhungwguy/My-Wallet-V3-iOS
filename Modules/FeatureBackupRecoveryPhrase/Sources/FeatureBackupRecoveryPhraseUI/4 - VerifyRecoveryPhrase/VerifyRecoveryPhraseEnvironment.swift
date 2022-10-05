import ComposableArchitecture
import DIKit
import Extensions
import FeatureBackupRecoveryPhraseDomain
import Foundation
import WalletPayloadKit

public struct VerifyRecoveryPhraseEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let recoveryPhraseRepository: RecoveryPhraseRepositoryAPI
    public let recoveryPhraseService: RecoveryPhraseVerifyingServiceAPI
    public let onNext: () -> Void
    public var generator = NonRandomNumberGenerator(
        [
            16864412655522353077
        ]
    )

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        recoveryPhraseRepository: RecoveryPhraseRepositoryAPI,
        recoveryPhraseService: RecoveryPhraseVerifyingServiceAPI,
        onNext: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.recoveryPhraseService = recoveryPhraseService
        self.recoveryPhraseRepository = recoveryPhraseRepository
        self.onNext = onNext
    }
}
