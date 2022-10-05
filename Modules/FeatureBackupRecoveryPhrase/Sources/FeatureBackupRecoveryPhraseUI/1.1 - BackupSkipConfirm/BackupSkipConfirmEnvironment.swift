import BlockchainNamespace
import ComposableArchitecture
import DIKit
import Foundation

public struct BackupSkipConfirmEnvironment {
    public let onConfirm: () -> Void

    public init(
        onConfirm: @escaping () -> Void
    ) {
        self.onConfirm = onConfirm
    }
}
