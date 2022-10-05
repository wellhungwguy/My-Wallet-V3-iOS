import ComposableArchitecture

public enum BackupRecoveryPhraseFailedModule {}

extension BackupRecoveryPhraseFailedModule {
    public static var reducer: Reducer<BackupRecoveryPhraseFailedState, BackupRecoveryPhraseFailedAction, BackupRecoveryPhraseFailedEnvironment> {
        .init { _, action, environment in
            switch action {
            case .onOkTapped:
                environment.onConfirm()
                return .none
            case .onReportABugTapped:
                return .none
            }
        }
    }
}
