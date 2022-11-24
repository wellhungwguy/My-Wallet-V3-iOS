// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public struct Wrapper: Equatable {
    public let pbkdf2Iterations: UInt32
    public let version: Int
    public let payloadChecksum: String
    public let language: String
    public let syncPubKeys: Bool
    public let wallet: NativeWallet

    public var isLatestVersion: Bool {
        version == PayloadCrypto.Constants.supportedEncryptionVersion
    }

    public init(
        pbkdf2Iterations: Int,
        version: Int,
        payloadChecksum: String?,
        language: String,
        syncPubKeys: Bool,
        wallet: NativeWallet
    ) {
        self.pbkdf2Iterations = UInt32(pbkdf2Iterations)
        self.version = version
        self.payloadChecksum = payloadChecksum ?? ""
        self.language = language
        self.syncPubKeys = syncPubKeys
        self.wallet = wallet
    }

    public init(
        walletPayload: WalletPayload,
        wallet: NativeWallet
    ) {
        self.version = walletPayload.payloadWrapper?.version ?? 4
        self.pbkdf2Iterations = walletPayload.payloadWrapper?.pbkdf2IterationCount ?? 5000
        self.payloadChecksum = walletPayload.payloadChecksum ?? ""
        self.language = walletPayload.language
        self.syncPubKeys = walletPayload.shouldSyncPubKeys
        self.wallet = wallet
    }
}

// MARK: - Update Method

func updateWrapper(
    nativeWallet: NativeWallet
) -> (Wrapper) -> Wrapper {
    { currentWrapper in
        Wrapper(
            pbkdf2Iterations: Int(currentWrapper.pbkdf2Iterations),
            version: currentWrapper.version,
            payloadChecksum: currentWrapper.payloadChecksum,
            language: currentWrapper.language,
            syncPubKeys: currentWrapper.syncPubKeys,
            wallet: nativeWallet
        )
    }
}

// MARK: - Creation Methods

func generateWrapper(
    wallet: NativeWallet,
    language: String = "en",
    version: WalletVersion = WalletVersion.supportedVersion
) -> Wrapper {
    Wrapper(
        pbkdf2Iterations: wallet.options.pbkdf2Iterations,
        version: version.rawValue,
        payloadChecksum: "",
        language: language,
        syncPubKeys: false,
        wallet: wallet
    )
}
