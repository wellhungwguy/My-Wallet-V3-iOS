// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationDomain
import RxSwift
import ToolKit
import WalletPayloadKit

final class CredentialsStore: CredentialsStoreAPI {

    // MARK: Types

    enum CredentialsStoreError: Error {
        case incompleteData
        case backupNotNeeded
    }

    private enum PBKDF2Iterations {
        static let guid: Int = 5001
        static let sharedKey: Int = 5002
    }

    private enum Keys: String {
        case data = "BC_KV_DATA"
        case guid = "BC_KV_GUID"
        case sharedKey = "BC_KV_SHARED_KEY"
        case pinKey = "BC_KV_PIN_KEY"
        case encryptedPinPassword = "BC_KV_ENCRYPTED_PIN_PWD"
    }

    // MARK: Private Properties

    private let appSettingsAuthenticating: AppSettingsAuthenticating
    private let sharedKeyRepository: SharedKeyRepositoryAPI
    private let guidRepository: GuidRepositoryAPI
    private let store: UbiquitousKeyValueStore
    private let cryptoService: WalletCryptoServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: Init

    init(
        appSettingsAuthenticating: AppSettingsAuthenticating = resolve(),
        sharedKeyRepository: SharedKeyRepositoryAPI = resolve(),
        guidRepository: GuidRepositoryAPI = resolve(),
        store: UbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default,
        cryptoService: WalletCryptoServiceAPI = resolve()
    ) {
        self.appSettingsAuthenticating = appSettingsAuthenticating
        self.guidRepository = guidRepository
        self.sharedKeyRepository = sharedKeyRepository
        self.store = store
        self.cryptoService = cryptoService
    }

    func erase() {
        store.set(nil, forKey: Keys.data.rawValue)
        synchronize()
    }

    func backup(pinDecryptionKey: String) -> Completable {
        let pinData = Single.just(pinData())
        let walletData = walletData(pinDecryptionKey: pinDecryptionKey)
            .optional()
            .catchAndReturn(nil)
        return Single
            .zip(
                appSettingsAuthenticating.pinKey,
                appSettingsAuthenticating.encryptedPinPassword,
                guidRepository.guid.asSingle(),
                sharedKeyRepository.sharedKey.asSingle(),
                pinData,
                walletData
            ) { (pinKey: $0, encryptedPinPassword: $1, guid: $2, sharedKey: $3, pinData: $4, walletData: $5) }
            .map { data -> (pinKey: String, encryptedPinPassword: String, guid: String, sharedKey: String) in
                guard
                    let pinKey = data.pinKey,
                    let encryptedPinPassword = data.encryptedPinPassword,
                    let guid = data.guid,
                    let sharedKey = data.sharedKey
                else {
                    throw CredentialsStoreError.incompleteData
                }

                // If we have both pin data and wallet data, we check that at least one of the values
                // needs to be updated. If none of them needs to be updated, we abort with '.backupNotNeeded'
                if let pinData = data.pinData, let walletData = data.walletData {
                    guard
                        pinData.encryptedPinPassword != encryptedPinPassword
                        || pinData.pinKey != pinKey
                        || walletData.guid != guid
                        || walletData.sharedKey != sharedKey
                    else {
                        throw CredentialsStoreError.backupNotNeeded
                    }
                }
                return (pinKey: pinKey, encryptedPinPassword: encryptedPinPassword, guid: guid, sharedKey: sharedKey)
            }
            .flatMapCompletable(weak: self) { (self, data) in
                self.backup(
                    pinDecryptionKey: pinDecryptionKey,
                    pinKey: data.pinKey,
                    encryptedPinPassword: data.encryptedPinPassword,
                    guid: data.guid,
                    sharedKey: data.sharedKey
                )
            }
            .catch { error in
                switch error {
                case CredentialsStoreError.backupNotNeeded:
                    return .empty()
                default:
                    throw error
                }
            }
    }

    private func backup(
        pinDecryptionKey: String,
        pinKey: String,
        encryptedPinPassword: String,
        guid: String,
        sharedKey: String
    ) -> Completable {
        Single
            .zip(
                cryptoService.encrypt(
                    pair: KeyDataPair(
                        key: pinDecryptionKey,
                        data: guid
                    ),
                    pbkdf2Iterations: PBKDF2Iterations.guid
                )
                .asObservable()
                .take(1)
                .asSingle(),
                cryptoService.encrypt(
                    pair: KeyDataPair(
                        key: pinDecryptionKey,
                        data: sharedKey
                    ),
                    pbkdf2Iterations: PBKDF2Iterations.sharedKey
                )
                .asObservable()
                .take(1)
                .asSingle()
            )
            .do(
                onSuccess: { [weak self] payload in
                    let (encryptedGuid, encryptedSharedKey) = payload
                    let data = [
                        Keys.pinKey.rawValue: pinKey,
                        Keys.encryptedPinPassword.rawValue: encryptedPinPassword,
                        Keys.guid.rawValue: encryptedGuid,
                        Keys.sharedKey.rawValue: encryptedSharedKey
                    ]
                    self?.store.set(data, forKey: Keys.data.rawValue)
                    self?.synchronize()
                }
            )
            .asCompletable()
    }

    func pinData() -> CredentialsPinData? {
        guard
            let data = store.dictionary(forKey: Keys.data.rawValue),
            let pinKey = data[Keys.pinKey.rawValue] as? String,
            let encryptedPinPassword = data[Keys.encryptedPinPassword.rawValue] as? String
        else { return nil }
        return CredentialsPinData(
            pinKey: pinKey,
            encryptedPinPassword: encryptedPinPassword
        )
    }

    func walletData(pinDecryptionKey: String) -> Single<CredentialsWalletData> {
        guard
            let data = store.dictionary(forKey: Keys.data.rawValue),
            let encryptedGuid = data[Keys.guid.rawValue] as? String,
            let encryptedSharedKey = data[Keys.sharedKey.rawValue] as? String
        else { return .error(CredentialsStoreError.incompleteData) }
        return Single
            .zip(
                cryptoService.decrypt(
                    pair: KeyDataPair(
                        key: pinDecryptionKey,
                        data: encryptedGuid
                    ),
                    pbkdf2Iterations: PBKDF2Iterations.guid
                )
                .asObservable()
                .take(1)
                .asSingle(),
                cryptoService.decrypt(
                    pair: KeyDataPair(
                        key: pinDecryptionKey,
                        data: encryptedSharedKey
                    ),
                    pbkdf2Iterations: PBKDF2Iterations.sharedKey
                )
                .asObservable()
                .take(1)
                .asSingle()
            )
            .map { payload in
                let (guid, sharedKey) = payload
                return CredentialsWalletData(guid: guid, sharedKey: sharedKey)
            }
    }

    func synchronize() {
        let result = store.synchronize()
        assert(result, "UbiquitousKeyValueStore synchronize: false")
    }
}
