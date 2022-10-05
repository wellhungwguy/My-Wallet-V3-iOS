import ComposableArchitecture
import Foundation

public struct BackupRecoveryPhraseFailedEnvironment {
    public let onConfirm: () -> Void

    public init(
        onConfirm: @escaping () -> Void
    ) {
        self.onConfirm = onConfirm
    }
}
