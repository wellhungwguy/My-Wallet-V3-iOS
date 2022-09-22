import ComposableArchitecture
import ComposableNavigation

public enum UserDeletionAction: BindableAction, NavigationAction {
    case binding(BindingAction<UserDeletionState>)
    case dismissFlow
    case onAppear
    case onConfirmViewChanged(DeletionConfirmAction)
    case route(RouteIntent<UserDeletionRoute>?)
    case showConfirmationScreen
}
