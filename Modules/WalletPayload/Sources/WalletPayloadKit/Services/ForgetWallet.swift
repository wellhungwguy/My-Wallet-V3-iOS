// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

public enum ForgetWalletError: Error {
    case failure(WalletRepoPersistenceError)
}

public protocol ForgetWalletAPI {
    func forget() -> AnyPublisher<Void, ForgetWalletError>
}

public protocol LegacyForgetWalletAPI {
    func forgetWallet()
}

final class ForgetWallet: ForgetWalletAPI {

    let legacyForgetWallet: LegacyForgetWalletAPI
    let walletRepo: WalletRepoAPI
    let walletState: WalletHolderAPI
    let walletPersistence: WalletRepoPersistenceAPI

    init(
        legacyForgetWallet: LegacyForgetWalletAPI,
        walletRepo: WalletRepoAPI,
        walletState: WalletHolderAPI,
        walletPersistence: WalletRepoPersistenceAPI
    ) {
        self.legacyForgetWallet = legacyForgetWallet
        self.walletRepo = walletRepo
        self.walletState = walletState
        self.walletPersistence = walletPersistence
    }

    func forget() -> AnyPublisher<Void, ForgetWalletError> {
        Deferred { [legacyForgetWallet, walletRepo, walletState, walletPersistence] ()
            -> AnyPublisher<Void, ForgetWalletError> in
            legacyForgetWallet.forgetWallet()
            walletRepo.set(value: .empty)
            walletState.release()
            return walletPersistence
                .delete()
                .mapError(ForgetWalletError.failure)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
