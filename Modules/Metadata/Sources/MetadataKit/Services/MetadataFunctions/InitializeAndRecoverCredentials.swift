// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

typealias InitializeAndRecoverCredentials =
    (Mnemonic) -> AnyPublisher<RecoveryContext, MetadataInitialisationAndRecoveryError>

func provideInitializeAndRecoverCredentials(
    fetch: @escaping FetchMetadataEntry
) -> InitializeAndRecoverCredentials {
    provideInitializeAndRecoverCredentials(
        fetchEntry: provideFetchEntry(fetch: fetch)
    )
}

func provideInitializeAndRecoverCredentials(
    fetchEntry: @escaping FetchEntry
) -> InitializeAndRecoverCredentials {
    { mnemonic in
        initializeAndRecoverCredentials(
            from: mnemonic,
            fetchEntry: fetchEntry
        )
    }
}

private func initializeAndRecoverCredentials(
    from mnemonic: Mnemonic,
    fetchEntry: @escaping FetchEntry
) -> AnyPublisher<RecoveryContext, MetadataInitialisationAndRecoveryError> {
    generateMasterKey(from: mnemonic)
        .publisher
        .mapError(MetadataInitialisationAndRecoveryError.failedToDeriveMasterKey)
        .flatMap { masterKey
            -> AnyPublisher<RemoteMetadataNodes, MetadataInitialisationAndRecoveryError> in
            deriveRemoteMetadataHdNodes(from: masterKey)
                .publisher
                .mapError(
                    MetadataInitialisationAndRecoveryError.failedToDeriveRemoteMetadataNode
                )
                .eraseToAnyPublisher()
        }
        .flatMap { remoteMetadataNodes
            -> AnyPublisher<RecoveryContext, MetadataInitialisationAndRecoveryError> in
            recoverSecondPasswordNode(with: remoteMetadataNodes, fetchEntry: fetchEntry)
                .map { credentials, secondPasswordNode in
                    let metadataState = MetadataState(
                        metadataNodes: remoteMetadataNodes,
                        secondPasswordNode: secondPasswordNode
                    )
                    return RecoveryContext(
                        metadataState: metadataState,
                        credentials: credentials
                    )
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}

private func recoverSecondPasswordNode(
    with remoteMetadataHdNodes: RemoteMetadataNodes,
    fetchEntry: @escaping FetchEntry
) -> AnyPublisher<(Credentials, SecondPasswordNode), MetadataInitialisationAndRecoveryError> {
    fetchEntry(.walletCredentials, remoteMetadataHdNodes)
        .decodeEntry()
        .mapError(MetadataInitialisationAndRecoveryError.failedToFetchCredentials)
        .map { (payload: WalletCredentialsEntryPayload) in
            Credentials(
                guid: payload.guid,
                sharedKey: payload.sharedKey,
                password: payload.password
            )
        }
        .flatMap { credentials
            -> AnyPublisher<(Credentials, SecondPasswordNode), MetadataInitialisationAndRecoveryError> in
            deriveSecondPasswordNode(credentials: credentials)
                .map { secondPasswordNode in
                    (credentials, secondPasswordNode)
                }
                .mapError(
                    MetadataInitialisationAndRecoveryError.failedToDeriveSecondPasswordNode
                )
                .publisher
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}

private func generateMasterKey(
    from mnemonic: Mnemonic
) -> Result<MasterKey, MasterKeyError> {
    MasterKey.from(masterNode: mnemonic.seedHex)
}
