// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class SharedKeyRepository: SharedKeyRepositoryAPI {

    let sharedKey: AnyPublisher<String?, Never>

    private let legacySharedKeyRepository: LegacySharedKeyRepositoryAPI
    private let walletRepo: WalletRepoAPI

    init(
        legacySharedKeyRepository: LegacySharedKeyRepositoryAPI,
        walletRepo: WalletRepoAPI
    ) {
        self.legacySharedKeyRepository = legacySharedKeyRepository
        self.walletRepo = walletRepo

        sharedKey = Deferred { [walletRepo, legacySharedKeyRepository] in
            walletRepo
                .get()
                .map(\.credentials.sharedKey)
                .flatMap { key -> AnyPublisher<String?, Never> in
                    guard !key.isEmpty else {
                        return legacySharedKeyRepository.sharedKey
                            .flatMap { legacyRepoKey -> AnyPublisher<String?, Never> in
                                guard let legacyRepoKey = legacyRepoKey else {
                                    return .just(nil)
                                }
                                walletRepo.set(keyPath: \.credentials.sharedKey, value: legacyRepoKey)
                                return .just(legacyRepoKey)
                            }
                            .eraseToAnyPublisher()
                    }
                    return .just(key)
                }
        }
        .eraseToAnyPublisher()
    }

    func set(sharedKey: String) -> AnyPublisher<Void, Never> {
        Deferred { [legacySharedKeyRepository, walletRepo] in
            legacySharedKeyRepository.set(sharedKey: sharedKey)
                .zip(
                    walletRepo.set(keyPath: \.credentials.sharedKey, value: sharedKey).get()
                )
                .mapToVoid()
        }
        .eraseToAnyPublisher()
    }
}
