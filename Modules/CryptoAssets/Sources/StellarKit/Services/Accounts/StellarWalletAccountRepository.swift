// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MetadataKit
import MoneyKit
import PlatformKit
import ToolKit
import WalletPayloadKit

enum StellarWalletAccountRepositoryError: Error {
    case saveFailure
    case mnemonicFailure(MnemonicAccessError)
    case metadataFetchError(WalletAssetFetchError)
    case failedToDeriveInput(Error)
}

protocol StellarWalletAccountRepositoryAPI {
    var defaultAccount: AnyPublisher<StellarWalletAccount?, Never> { get }
    func initializeMetadata() -> AnyPublisher<Void, StellarWalletAccountRepositoryError>
    func loadKeyPair() -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError>
}

final class StellarWalletAccountRepository: StellarWalletAccountRepositoryAPI {
    typealias WalletAccount = StellarWalletAccount

    private struct Key: Hashable {}

    /// The default `StellarWallet`, will be nil if it has not yet been initialized
    var defaultAccount: AnyPublisher<StellarWalletAccount?, Never> {
        cachedValue.get(key: Key())
            .map(\.first)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private let keyPairDeriver: StellarKeyPairDeriver
    private let metadataEntryService: WalletMetadataEntryServiceAPI
    private let mnemonicAccessAPI: MnemonicAccessAPI
    private let cachedValue: CachedValueNew<
        Key,
        [StellarWalletAccount],
        StellarWalletAccountRepositoryError
    >

    init(
        keyPairDeriver: StellarKeyPairDeriver = .init(),
        metadataEntryService: WalletMetadataEntryServiceAPI,
        mnemonicAccessAPI: MnemonicAccessAPI
    ) {
        self.keyPairDeriver = keyPairDeriver
        self.metadataEntryService = metadataEntryService
        self.mnemonicAccessAPI = mnemonicAccessAPI

        let cache: AnyCache<Key, [StellarWalletAccount]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { _ -> AnyPublisher<[StellarWalletAccount], StellarWalletAccountRepositoryError> in
                metadataEntryService.fetchEntry(type: StellarEntryPayload.self)
                    .map(\.accounts)
                    .map { accounts in
                        accounts.enumerated().map { index, account in
                            StellarWalletAccount(
                                index: index,
                                publicKey: account.publicKey,
                                label: account.label,
                                archived: account.archived
                            )
                        }
                    }
                    .mapError(StellarWalletAccountRepositoryError.metadataFetchError)
                    .eraseToAnyPublisher()
            }
        )
    }

    func initializeMetadata() -> AnyPublisher<Void, StellarWalletAccountRepositoryError> {
        metadataEntryService
            .fetchEntry(type: StellarEntryPayload.self)
            .mapToVoid()
            .catch { [createAndSaveStellarAccount] error -> AnyPublisher<Void, StellarWalletAccountRepositoryError> in
                guard case .fetchFailed(.loadMetadataError(.notYetCreated)) = error else {
                    return .failure(.metadataFetchError(error))
                }
                return createAndSaveStellarAccount()
            }
            .eraseToAnyPublisher()
    }

    func loadKeyPair() -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
        mnemonicAccessAPI
            .mnemonic
            .mapError(StellarWalletAccountRepositoryError.mnemonicFailure)
            .map(StellarKeyDerivationInput.init(mnemonic:))
            .flatMap { [keyPairDeriver] input in
                derive(input: input, deriver: keyPairDeriver)
            }
            .eraseToAnyPublisher()
    }

    // MARK: Private

    private func createAndSaveStellarAccount() -> AnyPublisher<Void, StellarWalletAccountRepositoryError> {
        loadKeyPair()
            .flatMap { [metadataEntryService] keyPair in
                saveNatively(
                    metadataEntryService: metadataEntryService,
                    keyPair: keyPair
                )
                .mapError { _ in StellarWalletAccountRepositoryError.saveFailure }
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

private func saveNatively(
    metadataEntryService: WalletMetadataEntryServiceAPI,
    keyPair: StellarKeyPair
) -> AnyPublisher<StellarKeyPair, StellarAccountError> {
    let account = StellarEntryPayload.Account(
        archived: false,
        label: CryptoCurrency.stellar.defaultWalletName,
        publicKey: keyPair.accountID
    )
    let payload = StellarEntryPayload(
        accounts: [account],
        defaultAccountIndex: 0,
        txNotes: [:]
    )
    return metadataEntryService.save(node: payload)
        .mapError { _ in StellarAccountError.unableToSaveNewAccount }
        .map { _ in keyPair }
        .eraseToAnyPublisher()
}

private func derive(
    input: StellarKeyDerivationInput,
    deriver: StellarKeyPairDeriver
) -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
    Deferred {
        Future { promise in
            switch deriver.derive(input: input) {
            case .success(let success):
                promise(.success(success))
            case .failure(let error):
                promise(.failure(.failedToDeriveInput(error)))
            }
        }
    }
    .eraseToAnyPublisher()
}
