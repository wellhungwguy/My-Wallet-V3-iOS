// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import WalletPayloadKit

public enum RecoveryPhraseRepositoryError: Error {
    case networkError(NetworkError)
    case missingCredentials(MissingCredentialsError)
}

public protocol RecoveryPhraseRepositoryAPI {
    /// Sends an email to the user's email (tied to the wallet) alerting them the recovery phrase has been exposed. Expected to be used when the recovery phrase is shown on screen.
    /// - Returns: A `Combine.Publisher` that publishes a `Void` if success or `RecoveryPhraseRepositoryError` if failed.
    func sendExposureAlertEmail() -> AnyPublisher<Void, RecoveryPhraseRepositoryError>

    /// Sends a signal to the backend server that the recovery phrase has been backup by user. Expected to be used when the user finished the recovery phrase backup process.
    /// - Returns: A `Combine.Publisher` that publishes a `Void` if success or `RecoveryPhraseRepositoryError` if failed.
    func updateMnemonicBackup() -> AnyPublisher<Void, RecoveryPhraseRepositoryError>
}
