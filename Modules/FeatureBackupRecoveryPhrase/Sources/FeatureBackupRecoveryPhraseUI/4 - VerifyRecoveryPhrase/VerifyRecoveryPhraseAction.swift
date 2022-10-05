import ComposableArchitecture
import FeatureBackupRecoveryPhraseDomain

public enum VerifyRecoveryPhraseAction: Equatable, BindableAction {
    case onAppear
    case onAvailableWordTap(RecoveryPhraseWord)
    case onSelectedWordTap(RecoveryPhraseWord)
    case onVerifyTap
    case onPhraseVerifySuccess
    case onPhraseVerifyFailed
    case onPhraseVerifyComplete
    case onPhraseVerifyBackupFailed
    case onResetWordsTap
    case onRecoveryPhraseComponentsFetchSuccess([RecoveryPhraseWord])
    case onRecoveryPhraseComponentsFetchedFailed
    case binding(BindingAction<VerifyRecoveryPhraseState>)
}
