import BlockchainNamespace
import ComposableArchitecture

public enum BackupRecoveryPhraseSuccessModule {}

extension BackupRecoveryPhraseSuccessModule {
    public static var reducer: Reducer<BackupRecoveryPhraseSuccessState, BackupRecoveryPhraseSuccessAction, BackupRecoveryPhraseSuccessEnvironment> {
        .init { _, action, environment in
            switch action {
            case .onDoneTapped:
                environment.onNext()
                return .none
            }
        }
    }
}
