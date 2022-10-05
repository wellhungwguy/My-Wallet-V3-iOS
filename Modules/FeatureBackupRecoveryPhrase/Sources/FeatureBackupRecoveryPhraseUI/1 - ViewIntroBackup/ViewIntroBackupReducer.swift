import ComposableArchitecture

public enum ViewIntroBackupModule {}

extension ViewIntroBackupModule {
    public static var reducer: Reducer<ViewIntroBackupState, ViewIntroBackupAction, ViewIntroBackupEnvironment> {
        .init { state, action, environment in
            switch action {
            case .onAppear:
                return .none

            case .onRecoveryPhraseStatusFetched(let isBackedUp):
                state.recoveryPhraseBackedUp = isBackedUp
                return .none

            case .onBackupNow:
                environment.onNext()
                return .none
            case .onSkipTap:
                environment.onSkip()
                return .none
            case .binding:
                return .none
            }
        }
        .binding()
    }
}
