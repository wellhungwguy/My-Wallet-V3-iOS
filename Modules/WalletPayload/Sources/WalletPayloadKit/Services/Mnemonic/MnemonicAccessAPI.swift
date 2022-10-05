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
}

// MARK: - Implementation

final class MnemonicAccessService: MnemonicAccessAPI {

    var mnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> {
        walletHolder.walletStatePublisher
            .first()
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

    private let walletHolder: WalletHolderAPI

    init(
        walletHolder: WalletHolderAPI
    ) {
        self.walletHolder = walletHolder
    }
}
