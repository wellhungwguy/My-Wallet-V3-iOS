// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureBackupRecoveryPhraseDomain
import Foundation

class RecoveryPhraseRepositoryMock: RecoveryPhraseRepositoryAPI {
    var sendExposureAlertEmailCalled = false
    var updateMnemonicBackupCalled = false

    func sendExposureAlertEmail() -> AnyPublisher<Void, RecoveryPhraseRepositoryError> {
        sendExposureAlertEmailCalled = true
        return .just(())
    }

    func updateMnemonicBackup() -> AnyPublisher<Void, RecoveryPhraseRepositoryError> {
        updateMnemonicBackupCalled = true
        return .just(())
    }
}

class RecoveryPhraseVerifyingServiceMock: RecoveryPhraseVerifyingServiceAPI {
    public var recoveryPhraseComponentsSubject = CurrentValueSubject<[RecoveryPhraseWord], RecoveryPhraseVerificationError>([])

    var recoveryPhraseComponentsCalled = false
    func recoveryPhraseComponents() -> AnyPublisher<[RecoveryPhraseWord], RecoveryPhraseVerificationError> {
        recoveryPhraseComponentsCalled = true
        return recoveryPhraseComponentsSubject.eraseToAnyPublisher()
    }

    var markBackupVerifiedCalled = false
    var markBackupVerifiedSubject = CurrentValueSubject<Void, RecoveryPhraseVerificationError>(())

    func markBackupVerified() -> AnyPublisher<Void, RecoveryPhraseVerificationError> {
        markBackupVerifiedCalled = true
        return .just(())
    }
}

enum MockGenerator {
    static var mockedWords = [
        RecoveryPhraseWord(label: "Word1"),
        RecoveryPhraseWord(label: "Word2"),
        RecoveryPhraseWord(label: "Word3"),
        RecoveryPhraseWord(label: "Word4"),
        RecoveryPhraseWord(label: "Word5"),
        RecoveryPhraseWord(label: "Word6"),
        RecoveryPhraseWord(label: "Word7"),
        RecoveryPhraseWord(label: "Word8"),
        RecoveryPhraseWord(label: "Word9"),
        RecoveryPhraseWord(label: "Word10"),
        RecoveryPhraseWord(label: "Word11"),
        RecoveryPhraseWord(label: "Word12")
    ]
}
