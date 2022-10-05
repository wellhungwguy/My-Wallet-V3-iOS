import ComposableArchitecture

public enum BackupSkipConfirmModule {}

extension BackupSkipConfirmModule {
    public static var reducer: Reducer<BackupSkipConfirmState, BackupSkipConfirmAction, BackupSkipConfirmEnvironment> {
        .init { _, action, environment in
            switch action {
            case .onConfirmTapped:
                environment.onConfirm()
                return .none
            }
        }
    }
}
