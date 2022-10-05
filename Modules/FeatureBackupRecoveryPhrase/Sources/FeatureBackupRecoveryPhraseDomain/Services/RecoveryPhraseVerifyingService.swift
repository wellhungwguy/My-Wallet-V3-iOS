// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

public final class RecoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI {

    private let verifyMnemonicBackupService: VerifyMnemonicBackupServiceAPI
    private let mnemonicComponentsProviding: MnemonicComponentsProviding
    public init(
        verifyMnemonicBackupService: VerifyMnemonicBackupServiceAPI,
        mnemonicComponentsProviding: MnemonicComponentsProviding
    ) {
        self.verifyMnemonicBackupService = verifyMnemonicBackupService
        self.mnemonicComponentsProviding = mnemonicComponentsProviding
    }

    public func recoveryPhraseComponents() -> AnyPublisher<[RecoveryPhraseWord], RecoveryPhraseVerificationError> {
        mnemonicComponentsProviding
            .components
            .map { words in
                words.map { RecoveryPhraseWord(label: $0) }
            }
            .mapError { _ in
                RecoveryPhraseVerificationError.recoveryPhraseFetchFailed
            }
            .eraseToAnyPublisher()
    }

    public func markBackupVerified() -> AnyPublisher<Void, RecoveryPhraseVerificationError> {
        verifyMnemonicBackupService
            .markRecoveryPhraseAndSync()
            .mapError { _ in RecoveryPhraseVerificationError.verificationFailure }
            .replaceOutput(with: ())
            .eraseToAnyPublisher()
    }
}
