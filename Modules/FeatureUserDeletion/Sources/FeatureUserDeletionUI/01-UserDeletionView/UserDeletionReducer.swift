import ComposableArchitecture

public enum UserDeletionModule {}

extension UserDeletionModule {
    public static var reducer = Reducer<UserDeletionState, UserDeletionAction, UserDeletionEnvironment>
        .combine(
            DeletionConfirmModule
                .reducer
                .optional()
                .pullback(
                    state: \.confirmViewState,
                    action: /UserDeletionAction.onConfirmViewChanged,
                    environment: { env in
                        DeletionConfirmEnvironment(
                            mainQueue: .main,
                            userDeletionRepository: env.userDeletionRepository,
                            analyticsRecorder: env.analyticsRecorder,
                            dismissFlow: env.dismissFlow,
                            logoutAndForgetWallet: env.logoutAndForgetWallet
                        )
                    }
                ),
            userDeletionReducer
        )

    public static var userDeletionReducer: Reducer<UserDeletionState, UserDeletionAction, UserDeletionEnvironment> {
        .init { state, action, environment in
            switch action {
            case .route(let routeItent):
                state.route = routeItent
                return .none
            case .showConfirmationScreen:
                state.route = .navigate(to: .showConfirmationView)
                return .none
            case .dismissFlow:
                environment.dismissFlow()
                return .none
            default:
                return .none
            }
        }
        .binding()
    }
}
