import ComposableArchitecture
import Foundation

public struct DeletionResultEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let logoutAndForgetWallet: () -> Void
    public let dismissFlow: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        dismissFlow: @escaping () -> Void,
        logoutAndForgetWallet: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.dismissFlow = dismissFlow
        self.logoutAndForgetWallet = logoutAndForgetWallet
    }
}
