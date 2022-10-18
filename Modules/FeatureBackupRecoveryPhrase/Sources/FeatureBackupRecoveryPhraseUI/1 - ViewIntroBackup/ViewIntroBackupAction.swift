import ComposableArchitecture

public enum ViewIntroBackupAction: Equatable, BindableAction {
    case onAppear
    case onBackupNow
    case onSkipTap
    case binding(BindingAction<ViewIntroBackupState>)
    case onRecoveryPhraseStatusFetched(Bool)
}
