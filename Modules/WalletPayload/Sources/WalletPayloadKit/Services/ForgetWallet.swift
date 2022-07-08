// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

public enum ForgetWalletError: Error {
    case failure(WalletRepoPersistenceError)
}

public protocol ForgetWalletAPI {
    func forget() -> AnyPublisher<EmptyValue, ForgetWalletError>
}

final class ForgetWallet: ForgetWalletAPI {

    let walletRepo: WalletRepoAPI
    let walletState: WalletHolderAPI
    let walletPersistence: WalletRepoPersistenceAPI

    init(
        walletRepo: WalletRepoAPI,
        walletState: WalletHolderAPI,
        walletPersistence: WalletRepoPersistenceAPI
    ) {
        self.walletRepo = walletRepo
        self.walletState = walletState
        self.walletPersistence = walletPersistence
    }

    func forget() -> AnyPublisher<EmptyValue, ForgetWalletError> {
        walletRepo.set(value: .empty)
        walletState.release()
        return walletPersistence.delete()
            .mapError(ForgetWalletError.failure)
            .eraseToAnyPublisher()
    }
}
