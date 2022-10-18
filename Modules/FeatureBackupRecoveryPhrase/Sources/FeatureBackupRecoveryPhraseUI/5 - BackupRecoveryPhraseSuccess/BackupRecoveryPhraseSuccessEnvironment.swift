import BlockchainNamespace
import ComposableArchitecture
import DIKit
import Foundation

public struct BackupRecoveryPhraseSuccessEnvironment {
    public let onNext: () -> Void

    public init(
        onNext: @escaping () -> Void
    ) {
        self.onNext = onNext
    }
}
