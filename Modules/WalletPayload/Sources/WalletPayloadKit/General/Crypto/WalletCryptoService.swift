// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

public enum WalletCryptoPBKDF2Iterations {
    /// Used for Auto Pair QR code decryption/encryption
    public static let autoPair = 10
    /// This does not need to be large because the key is already 256 bits
    public static let pinLogin = 1
}

public protocol WalletCryptoServiceAPI: AnyObject {
    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> AnyPublisher<String, PayloadCryptoError>
    func encrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> AnyPublisher<String, PayloadCryptoError>
}

final class WalletCryptoService: WalletCryptoServiceAPI {

    // MARK: - Properties

    private let payloadCryptor: WalletPayloadCryptorAPI
    private let recorder: Recording

    // MARK: - Setup

    init(
        payloadCryptor: WalletPayloadCryptorAPI = resolve(),
        recorder: Recording = resolve(tag: "CrashlyticsRecorder")
    ) {
        self.payloadCryptor = payloadCryptor
        self.recorder = recorder
    }

    // MARK: - Public methods

    /// Receives a `KeyDataPair` and decrypt `data` using `key`
    /// - Parameter pair: A pair of key and data used in the decription process.
    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: Int) -> AnyPublisher<String, PayloadCryptoError> {
        decryptNative(pair: pair, pbkdf2Iterations: UInt32(pbkdf2Iterations))
            .publisher
            .eraseToAnyPublisher()
    }

    /// Receives a `KeyDataPair` and encrypt `data` using `key`.
    /// - Parameter pair: A pair of key and data used in the encription process.
    func encrypt(
        pair: KeyDataPair<String, String>,
        pbkdf2Iterations: Int
    ) -> AnyPublisher<String, PayloadCryptoError> {
        encryptNative(pair: pair, pbkdf2Iterations: UInt32(pbkdf2Iterations))
            .publisher
            .eraseToAnyPublisher()
    }

    // MARK: - Private methods

    private func encryptNative(
        pair: KeyDataPair<String, String>,
        pbkdf2Iterations: UInt32
    ) -> Result<String, PayloadCryptoError> {
        payloadCryptor.encrypt(pair: pair, pbkdf2Iterations: pbkdf2Iterations)
    }

    private func decryptNative(
        pair: KeyDataPair<String, String>,
        pbkdf2Iterations: UInt32
    ) -> Result<String, PayloadCryptoError> {
        payloadCryptor.decrypt(pair: pair, pbkdf2Iterations: pbkdf2Iterations)
    }
}
