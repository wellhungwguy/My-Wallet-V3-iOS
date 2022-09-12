// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public final class RecoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI {

    public var phraseComponents: [String] = []
    public var selection: [String] = []

    private let verifyMnemonicBackupService: VerifyMnemonicBackupServiceAPI

    public init(
        verifyMnemonicBackupService: VerifyMnemonicBackupServiceAPI
    ) {
        self.verifyMnemonicBackupService = verifyMnemonicBackupService
    }

    public func markBackupVerified() -> AnyPublisher<EmptyValue, RecoveryPhraseVerificationError> {
        verifyMnemonicBackupService.markRecoveryPhraseAndSync()
            .mapError { _ in RecoveryPhraseVerificationError.verificationFailure }
            .eraseToAnyPublisher()
    }
}
