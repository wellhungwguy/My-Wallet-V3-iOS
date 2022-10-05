import ComposableArchitecture
import FeatureBackupRecoveryPhraseDomain

public enum ManualBackupSeedPhraseAction: Equatable {
    case onAppear
    case onCopyTap
    case onNextTap
    case onCopyReturn
    case onRecoveryPhraseComponentsFetchSuccess([RecoveryPhraseWord])
    case onRecoveryPhraseComponentsFetchedFailed
}
