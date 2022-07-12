// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit
import WalletCore

// MARK: - Typealiases

public typealias WalletCoreHDWalletProvider = () -> AnyPublisher<WalletCore.HDWallet, WalletError>

// MARK: Wallet Core Providers

/// Returns a closure that outputs an HDWallet
/// - Parameter walletHolder: A `WalletHolderAPI` which provides the current wallet
/// - Returns: A `WalletCoreHDWalletProvider`
func provideWalletCoreHDWallet(
    walletHolder: WalletHolderAPI
) -> WalletCoreHDWalletProvider {
    { [walletHolder] () -> AnyPublisher<WalletCore.HDWallet, WalletError> in
        walletHolder.walletStatePublisher
            .flatMap { state -> AnyPublisher<WalletCore.HDWallet, WalletError> in
                guard let wallet = state?.wallet else {
                    return .failure(.initialization(.missingWallet))
                }
                return getSeedHex(from: wallet)
                    .map(Data.init(hex:))
                    .flatMap(getWalletCoreHDWallet(from:))
                    .publisher
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Private

// Gets an HDWallet from the given parameters
/// - Parameters:
///   - entropy: A `Data` value representing the entropy for the `HDWallet`
/// - Returns: A `Result<WalletCore.HDWallet, WalletError>`
private func getWalletCoreHDWallet(
    from entropy: Data
) -> Result<WalletCore.HDWallet, WalletError> {
    guard let hdWallet = WalletCore.HDWallet(entropy: entropy, passphrase: "") else {
        return .failure(.decryption(.hdWalletCreation))
    }
    return .success(hdWallet)
}
