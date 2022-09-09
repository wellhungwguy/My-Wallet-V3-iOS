import ComposableArchitecture
import ComposableNavigation
import Errors

public enum DeletionConfirmAction: BindableAction, NavigationAction {
    case binding(BindingAction<DeletionConfirmState>)
    case deleteUserAccount
    case dismissFlow
    case onAppear
    case onConfirmViewChanged(DeletionResultAction)
    case route(RouteIntent<UserDeletionResultRoute>?)
    case showResultScreen(result: Result<Void, NetworkError>)
    case validateConfirmationInput
}
