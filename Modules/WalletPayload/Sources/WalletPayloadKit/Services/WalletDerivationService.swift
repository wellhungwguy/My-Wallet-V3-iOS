// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit

public enum WalletDerivationServiceError: Error {
    case notInitialized
    case walletError(WalletError)
    case invalidDerivationPath
}

public protocol WalletDerivationServiceAPI {

    func privateKey(
        derivationPath: String,
        secondPassword: String?
    ) -> AnyPublisher<Data, WalletDerivationServiceError>

    func publicKey(
        derivationPath: String,
        secondPassword: String?
    ) -> AnyPublisher<Data, WalletDerivationServiceError>
}

final class WalletDerivationService: WalletDerivationServiceAPI {

    private let walletHolder: WalletHolderAPI

    init(walletHolder: WalletHolderAPI) {
        self.walletHolder = walletHolder
    }

    func privateKey(
        derivationPath: String,
        secondPassword: String?
    ) -> AnyPublisher<Data, WalletDerivationServiceError> {
        masterNode(secondPassword: secondPassword)
            .map { masterNode in
                derivePrivateKeyData(masterNode: masterNode, derivationPath: derivationPath)
            }
            .onNil(.invalidDerivationPath)
            .eraseToAnyPublisher()
    }

    func publicKey(
        derivationPath: String,
        secondPassword: String?
    ) -> AnyPublisher<Data, WalletDerivationServiceError> {
        masterNode(secondPassword: secondPassword)
            .map { masterNode in
                derivePublicKeyData(masterNode: masterNode, derivationPath: derivationPath)
            }
            .onNil(.invalidDerivationPath)
            .eraseToAnyPublisher()
    }

    private func masterNode(
        secondPassword: String?
    ) -> AnyPublisher<String, WalletDerivationServiceError> {
        walletHolder.walletStatePublisher
            .flatMap { state -> AnyPublisher<NativeWallet, WalletDerivationServiceError> in
                guard let wallet = state?.wallet else {
                    return .failure(.notInitialized)
                }
                return .just(wallet)
            }
            .flatMap { wallet -> AnyPublisher<String, WalletDerivationServiceError> in
                getMasterNode(from: wallet, secondPassword: secondPassword)
                    .publisher
                    .mapError(WalletDerivationServiceError.walletError)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
