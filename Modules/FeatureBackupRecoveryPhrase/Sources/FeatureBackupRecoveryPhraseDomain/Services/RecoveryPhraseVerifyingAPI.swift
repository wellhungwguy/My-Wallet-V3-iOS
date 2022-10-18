// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum RecoveryPhraseVerificationError: Error {
    case verificationFailure
    case recoveryPhraseFetchFailed
}

public protocol RecoveryPhraseVerifyingServiceAPI {
    func recoveryPhraseComponents() -> AnyPublisher<[RecoveryPhraseWord], RecoveryPhraseVerificationError>
    func markBackupVerified() -> AnyPublisher<Void, RecoveryPhraseVerificationError>
}
