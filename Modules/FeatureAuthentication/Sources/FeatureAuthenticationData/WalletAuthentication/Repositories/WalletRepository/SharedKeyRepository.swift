// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class SharedKeyRepository: SharedKeyRepositoryAPI {

    let sharedKey: AnyPublisher<String?, Never>

    // This is set to the older WalletRepository API, soon to be removed
    private let walletRepository: WalletRepositoryAPI
    private let walletRepo: WalletRepoAPI
    private let nativeWalletEnabled: () -> AnyPublisher<Bool, Never>

    init(
        walletRepository: WalletRepositoryAPI,
        walletRepo: WalletRepoAPI,
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.walletRepository = walletRepository
        self.walletRepo = walletRepo
        self.nativeWalletEnabled = nativeWalletEnabled

        sharedKey = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<String?, Never> in
                guard isEnabled else {
                    return walletRepository.sharedKey
                }
                return walletRepo
                    .get()
                    .map(\.credentials.sharedKey)
                    .flatMap { key -> AnyPublisher<String?, Never> in
                        guard !key.isEmpty else {
                            return walletRepository.sharedKey
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
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(sharedKey: String) -> AnyPublisher<Void, Never> {
        walletRepository.set(sharedKey: sharedKey)
            .zip(
                walletRepo.set(keyPath: \.credentials.sharedKey, value: sharedKey).get()
            )
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
