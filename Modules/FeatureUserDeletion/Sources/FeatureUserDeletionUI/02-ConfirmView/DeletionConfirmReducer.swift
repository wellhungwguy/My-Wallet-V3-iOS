import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureUserDeletionDomain
import Foundation

public enum DeletionConfirmModule {}

extension DeletionConfirmModule {
    public static var reducer = Reducer<DeletionConfirmState, DeletionConfirmAction, DeletionConfirmEnvironment>
        .combine(
            DeletionResultModule
                .reducer
                .optional()
                .pullback(
                    state: \.resultViewState,
                    action: /DeletionConfirmAction.onConfirmViewChanged,
                    environment: { env in
                        DeletionResultEnvironment(
                            mainQueue: .main,
                            dismissFlow: env.dismissFlow,
                            logoutAndForgetWallet: env.logoutAndForgetWallet
                        )
                    }
                ),
            deletionConfirmReducer
        )

    public static var deletionConfirmReducer: Reducer<DeletionConfirmState, DeletionConfirmAction, DeletionConfirmEnvironment> {
        .init { state, action, environment in
            switch action {
            case .showResultScreen(let success):
                state.resultViewState = DeletionResultState(success: success)
                state.route = .navigate(to: .showResultScreen)
                return .none
            case .deleteUserAccount:
                guard state.isConfirmationInputValid else {
                    return Effect(value: .validateConfirmationInput)
                }
                state.isLoading = true
                return environment
                    .userDeletionRepository
                    .deleteUser(with: nil)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> DeletionConfirmAction in
                        .showResultScreen(success: result.isSuccess)
                    }
            case .validateConfirmationInput:
                state.validateConfirmationInputField()
                return .none
            case .dismissFlow:
                environment.dismissFlow()
                return .none
            case .route(let routeItent):
                state.route = routeItent
                return .none
            case .binding(\.$textFieldText):
                return Effect(value: .validateConfirmationInput)
            case .onConfirmViewChanged:
                return .none
            default:
                return .none
            }
        }
        .binding()
    }
}
