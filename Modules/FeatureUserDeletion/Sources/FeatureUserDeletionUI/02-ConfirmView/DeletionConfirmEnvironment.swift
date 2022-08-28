import ComposableArchitecture
import FeatureUserDeletionDomain
import Foundation

public struct DeletionConfirmEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let userDeletionRepository: UserDeletionRepositoryAPI
    public let logoutAndForgetWallet: () -> Void
    public let dismissFlow: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        userDeletionRepository: UserDeletionRepositoryAPI,
        dismissFlow: @escaping () -> Void,
        logoutAndForgetWallet: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.userDeletionRepository = userDeletionRepository
        self.dismissFlow = dismissFlow
        self.logoutAndForgetWallet = logoutAndForgetWallet
    }
}
