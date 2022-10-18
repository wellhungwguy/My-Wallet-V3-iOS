// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CryptoKit
import CryptoSwift
import WalletCore

public enum ECDH {

    public enum ECDHError: Error {
        case hkdfError(Error)
        case aesError(Error)
        case aesSealedBoxMissingCombinedData
        case invalidPrivateKey
        case invalidPublicKey
        case invalidSharedKey
    }

    public static func derive(priv: Data, pub: Data) -> Result<Data, ECDHError> {
        privateKey(priv: priv)
            .flatMap { privateKey in
                publicKey(pub: pub)
                    .flatMap { publicKey in
                        sharedKey(privateKey: privateKey, publicKey: publicKey)
                    }
            }
            .flatMap { sharedKey -> Result<Data, ECDHError> in
                Result { try CryptoSwift.HKDF(password: sharedKey.bytes).calculate() }
                    .mapError(ECDHError.hkdfError)
                    .map { Data($0) }
            }
    }

    /// Returns a `Data` object representing the `Secp256k1` Shared Key between given `PrivateKey` and `PublicKey`.
    private static func sharedKey(privateKey: WalletCore.PrivateKey, publicKey: WalletCore.PublicKey) -> Result<Data, ECDHError> {
        Result
            .success(privateKey.getSharedKey(publicKey: publicKey, curve: .secp256k1))
            .flatMap { sharedKey -> Result<Data, ECDHError> in
                guard let sharedKey else {
                    return .failure(.invalidSharedKey)
                }
                return .success(sharedKey)
            }
    }

    /// Returns a `WalletCore.PrivateKey` for the given privKey `Data` object.
    private static func privateKey(priv: Data) -> Result<WalletCore.PrivateKey, ECDHError> {
        Result
            .success(WalletCore.PrivateKey(data: priv))
            .flatMap { privateKey -> Result<WalletCore.PrivateKey, ECDHError> in
                guard let privateKey else {
                    return .failure(.invalidPrivateKey)
                }
                return .success(privateKey)
            }
    }

    /// Returns a `Secp256k1` `WalletCore.PublicKey` for the given pubKey `Data` object.
    private static func publicKey(pub: Data) -> Result<WalletCore.PublicKey, ECDHError> {
        Result
            .success(WalletCore.PublicKey(data: pub, type: .secp256k1))
            .flatMap { publicKey -> Result<WalletCore.PublicKey, ECDHError> in
                guard let publicKey else {
                    return .failure(.invalidPublicKey)
                }
                return .success(publicKey)
            }
    }

    /// Returns a `Data` object representing the `Secp256k1` Public Key of given privKey `Data` object.
    public static func publicFromPrivate(priv: Data) -> Result<Data, ECDHError> {
        privateKey(priv: priv)
            .map { privateKey -> Data in
                privateKey.getPublicKeySecp256k1(compressed: true).data
            }
    }

    /// AES.GCM encrypts payload with SymmetricKey `priv`.
    public static func encrypt(priv: Data, payload: Data) -> Result<Data, ECDHError> {
        Result { try AES.GCM.seal(payload, using: SymmetricKey(data: priv)) }
            .mapError(ECDHError.aesError)
            .flatMap { sealedBox -> Result<Data, ECDHError> in
                guard let combined = sealedBox.combined else {
                    return .failure(.aesSealedBoxMissingCombinedData)
                }
                return .success(combined)
            }
    }

    /// AES.GCM decrypts payload with SymmetricKey `priv`.
    public static func decrypt(priv: Data, payload: Data) -> Result<Data, ECDHError> {
        Result { try AES.GCM.SealedBox(combined: payload) }
            .flatMap { sealedBox -> Result<Data, Error> in
                Result { try AES.GCM.open(sealedBox, using: SymmetricKey(data: priv)) }
            }
            .mapError(ECDHError.aesError)
    }
}
