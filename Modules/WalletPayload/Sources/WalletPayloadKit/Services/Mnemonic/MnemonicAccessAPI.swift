// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

public typealias Mnemonic = String

public enum MnemonicAccessError: Error {
    case generic
    case wrongSecondPassword
    case couldNotRetrieveMnemonic(WalletError)
}

/// Types adopting `MnemonicAccessAPI` should provide access to a mnemonic phrase.
public protocol MnemonicAccessAPI {

    /// Returns a `AnyPublisher<Mnemonic, MnemonicAccessError>` emitting
    /// a Mnemonic if and only if the mnemonic is not double encrypted
    var mnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> { get }

    /// Returns a `AnyPublisher<Mnemonic, MnemonicAccessError>` using optionally a second password
    /// - Parameter secondPassword: An optional `String` value for a double encrypted wallet
    func mnemonic(with secondPassword: String?) -> AnyPublisher<Mnemonic, MnemonicAccessError>

    /// Returns a `AnyPublisher<Mnemonic, MnemonicAccessError>` emitting a Mnemonic.
    /// This will prompt the user to enter the second password if needed.
    var mnemonicPromptingIfNeeded: AnyPublisher<Mnemonic, MnemonicAccessError> { get }
}

// MARK: "Proxies"

public protocol NativeMnemonicAccessAPI: MnemonicAccessAPI {}

public protocol LegacyMnemonicAccessAPI: MnemonicAccessAPI {}

// MARK: - Implementation

final class MnemonicAccessService: NativeMnemonicAccessAPI {

    var mnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> {
        walletHolder.walletStatePublisher
            .flatMap { state -> AnyPublisher<NativeWallet, MnemonicAccessError> in
                guard let wallet = state?.wallet else {
                    return .failure(.generic)
                }
                return .just(wallet)
            }
            .flatMap { wallet -> AnyPublisher<Mnemonic, MnemonicAccessError> in
                getMnemonic(from: wallet)
                    .publisher
                    .mapError { _ in MnemonicAccessError.wrongSecondPassword }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    var mnemonicPromptingIfNeeded: AnyPublisher<Mnemonic, MnemonicAccessError> {
        mnemonic
    }

    private let walletHolder: WalletHolderAPI

    init(
        walletHolder: WalletHolderAPI
    ) {
        self.walletHolder = walletHolder
    }

    func mnemonic(with secondPassword: String?) -> AnyPublisher<Mnemonic, MnemonicAccessError> {
        fatalError("iOS doesn't support second password")
    }
}
