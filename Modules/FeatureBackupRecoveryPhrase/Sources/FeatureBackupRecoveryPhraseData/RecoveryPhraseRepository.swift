// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import FeatureBackupRecoveryPhraseDomain

public final class RecoveryPhraseRepository: RecoveryPhraseRepositoryAPI {

    // MARK: - Properties

    private let exposureAlertClient: RecoveryPhraseExposureAlertClientAPI
    private let backupClient: RecoveryPhraseBackupClientAPI
    private let credentialsRepository: CredentialsRepositoryAPI

    // MARK: - Setup

    public init(
        exposureAlertClient: RecoveryPhraseExposureAlertClientAPI = resolve(),
        backupClient: RecoveryPhraseBackupClientAPI = resolve(),
        credentialsRepository: CredentialsRepositoryAPI = resolve()
    ) {
        self.exposureAlertClient = exposureAlertClient
        self.backupClient = backupClient
        self.credentialsRepository = credentialsRepository
    }

    public func sendExposureAlertEmail() -> AnyPublisher<Void, RecoveryPhraseRepositoryError> {
        Publishers.Zip(
            credentialsRepository.guid,
            credentialsRepository.sharedKey
        )
        .flatMap { [exposureAlertClient] guidOrNil, sharedKeyOrNil
            -> AnyPublisher<Void, RecoveryPhraseRepositoryError> in
            guard let guid = guidOrNil else {
                return .failure(.missingCredentials(.guid))
            }
            guard let sharedKey = sharedKeyOrNil else {
                return .failure(.missingCredentials(.sharedKey))
            }
            return exposureAlertClient
                .sendExposureAlertEmail(guid: guid, sharedKey: sharedKey)
                .mapError(RecoveryPhraseRepositoryError.networkError)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    public func updateMnemonicBackup() -> AnyPublisher<Void, RecoveryPhraseRepositoryError> {
        Publishers.Zip(
            credentialsRepository.guid,
            credentialsRepository.sharedKey
        )
        .flatMap { [backupClient] guidOrNil, sharedKeyOrNil -> AnyPublisher<Void, RecoveryPhraseRepositoryError> in
            guard let guid = guidOrNil else {
                return .failure(.missingCredentials(.guid))
            }
            guard let sharedKey = sharedKeyOrNil else {
                return .failure(.missingCredentials(.sharedKey))
            }
            return backupClient
                .updateMnemonicBackup(guid: guid, sharedKey: sharedKey)
                .mapError(RecoveryPhraseRepositoryError.networkError)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
