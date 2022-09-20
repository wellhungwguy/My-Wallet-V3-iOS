// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class SyncPubKeysRepository: SyncPubKeysRepositoryAPI {

    private let walletRepo: WalletRepoAPI

    init(
        walletRepo: WalletRepoAPI
    ) {
        self.walletRepo = walletRepo
    }

    func set(syncPubKeys: Bool) -> AnyPublisher<Void, Never> {
        Deferred { [walletRepo] in
            walletRepo
                .set(keyPath: \.properties.syncPubKeys, value: syncPubKeys)
                .get()
                .mapToVoid()
        }
        .eraseToAnyPublisher()
    }
}
