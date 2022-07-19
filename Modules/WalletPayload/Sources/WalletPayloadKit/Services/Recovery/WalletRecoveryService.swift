// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ObservabilityKit
import ToolKit
import WalletCore

public protocol WalletRecoveryServiceAPI {

    /// Recovers a wallet account using the given mnemonic
    /// - parameter mnemonic: A backup phrase to recover funds
    /// - Returns: `AnyPublisher<WalletState, WalletError>`
    func recover(
        from mnemonic: String
    ) -> AnyPublisher<WalletFetchedContext, WalletError>
}

struct WalletPayloadContext: Equatable {
    let payload: WalletPayload
    let credentials: MetadataRecoveryCredentials
}

struct DecryptedPayloadContext: Equatable {
    let walletPayload: WalletPayload
    let payload: String
    let guid: String
    let sharedKey: String
    let password: String
}

final class WalletRecoveryService: WalletRecoveryServiceAPI {

    private let walletLogic: WalletLogicAPI
    private let payloadCrypto: PayloadCryptoAPI
    private let walletRepo: WalletRepoAPI
    private let walletPayloadRepository: WalletPayloadRepositoryAPI
    private let operationsQueue: DispatchQueue
    private let tracer: LogMessageServiceAPI

    init(
        walletLogic: WalletLogicAPI,
        payloadCrypto: PayloadCryptoAPI,
        walletRepo: WalletRepoAPI,
        walletPayloadRepository: WalletPayloadRepositoryAPI,
        operationsQueue: DispatchQueue,
        tracer: LogMessageServiceAPI
    ) {
        self.walletLogic = walletLogic
        self.payloadCrypto = payloadCrypto
        self.walletRepo = walletRepo
        self.walletPayloadRepository = walletPayloadRepository
        self.operationsQueue = operationsQueue
        self.tracer = tracer
    }

    func recover(
        from mnemonic: String
    ) -> AnyPublisher<WalletFetchedContext, WalletError> {
        guard WalletCore.Mnemonic.isValid(mnemonic: mnemonic) else {
            return .failure(.recovery(.invalidMnemonic))
        }
        return walletLogic
            .initialize(with: mnemonic, on: operationsQueue)
            .receive(on: operationsQueue)
            .flatMap { [storeCredentials] credentials -> AnyPublisher<MetadataRecoveryCredentials, WalletError> in
                storeCredentials(credentials)
                    .first()
                    .mapError()
                    .map { _ in credentials }
                    .eraseToAnyPublisher()
            }
            .flatMap { [walletPayloadRepository] credentials -> AnyPublisher<WalletPayloadContext, WalletError> in
                walletPayloadRepository.payload(
                    guid: credentials.guid,
                    identifier: .sharedKey(credentials.sharedKey)
                )
                .map { WalletPayloadContext(payload: $0, credentials: credentials) }
                .mapError { _ in WalletError.payloadNotFound }
                .eraseToAnyPublisher()
            }
            .flatMap { [storeProperties] walletPayloadContext -> AnyPublisher<WalletPayloadContext, WalletError> in
                storeProperties(walletPayloadContext)
                    .first()
                    .mapError()
                    .eraseToAnyPublisher()
            }
            .flatMap { [payloadCrypto] walletPayloadContext -> AnyPublisher<DecryptedPayloadContext, WalletError> in
                let payloadWrapper = walletPayloadContext.payload.payloadWrapper
                let credentials = walletPayloadContext.credentials
                let password = credentials.password
                guard let wrapper = payloadWrapper, !wrapper.payload.isEmpty else {
                    return .failure(WalletError.payloadNotFound)
                }
                return payloadCrypto.decryptWallet(
                    walletWrapper: wrapper,
                    password: password
                )
                .publisher
                .mapError { _ in WalletError.decryption(.decryptionError) }
                .map { payload in
                    DecryptedPayloadContext(
                        walletPayload: walletPayloadContext.payload,
                        payload: payload,
                        guid: credentials.guid,
                        sharedKey: credentials.sharedKey,
                        password: password
                    )
                }
                .eraseToAnyPublisher()
            }
            .flatMap { [walletLogic] decryptedWalletPayloadContext
                -> AnyPublisher<DecryptedPayloadContext, WalletError> in
                guard let data = decryptedWalletPayloadContext.payload.data(using: .utf8) else {
                    return .failure(.decryption(.decryptionError))
                }
                return walletLogic.initializeAfterMetadataRecovery(
                    with: decryptedWalletPayloadContext.password,
                    payload: decryptedWalletPayloadContext.walletPayload,
                    decryptedWallet: data
                )
                .map { _ in decryptedWalletPayloadContext }
                .eraseToAnyPublisher()
            }
            .map { context in
                WalletFetchedContext(
                    guid: context.guid,
                    sharedKey: context.sharedKey,
                    passwordPartHash: hashPassword(context.password)
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func storeCredentials(
        model: MetadataRecoveryCredentials
    ) -> AnyPublisher<MetadataRecoveryCredentials, Never> {
        walletRepo
            .set(keyPath: \.credentials.guid, value: model.guid)
            .set(keyPath: \.credentials.sharedKey, value: model.sharedKey)
            .set(keyPath: \.credentials.password, value: model.password)
            .get()
            .map { _ in model }
            .eraseToAnyPublisher()
    }

    private func storeProperties(
        context: WalletPayloadContext
    ) -> AnyPublisher<WalletPayloadContext, Never> {
        let walletPayload = context.payload
        return walletRepo
            .set(keyPath: \.properties.language, value: walletPayload.language)
            .set(keyPath: \.properties.syncPubKeys, value: walletPayload.shouldSyncPubKeys)
            .set(keyPath: \.properties.authenticatorType, value: walletPayload.authenticatorType)
            .get()
            .map { _ in context }
            .eraseToAnyPublisher()
    }
}
