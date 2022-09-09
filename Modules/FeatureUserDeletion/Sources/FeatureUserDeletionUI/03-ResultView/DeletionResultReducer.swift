import AnalyticsKit
import ComposableArchitecture

public enum DeletionResultModule {}

extension DeletionResultModule {
    public static var reducer: Reducer<DeletionResultState, DeletionResultAction, DeletionResultEnvironment> {
        .init { _, action, environment in
            switch action {
            case .dismissFlow:
                environment.dismissFlow()
                return .none
            case .logoutAndForgetWallet:
                environment.logoutAndForgetWallet()
                return .none
            default:
                return .none
            }
        }
        .binding()
    }
}
