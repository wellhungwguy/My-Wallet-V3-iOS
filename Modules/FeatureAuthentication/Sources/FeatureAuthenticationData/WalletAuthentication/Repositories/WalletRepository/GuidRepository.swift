// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class GuidRepository: GuidRepositoryAPI {

    let guid: AnyPublisher<String?, Never>

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

        guid = nativeWalletEnabled()
            .flatMap { isEnabled -> AnyPublisher<String?, Never> in
                guard isEnabled else {
                    return walletRepository.guid
                }
                return walletRepo
                    .get()
                    .map(\.credentials.guid)
                    .flatMap { guid -> AnyPublisher<String?, Never> in
                        guard !guid.isEmpty else {
                            return walletRepository.guid
                                .flatMap { legacyRepoKey -> AnyPublisher<String?, Never> in
                                    guard let legacyRepoValue = legacyRepoKey else {
                                        return .just(nil)
                                    }
                                    walletRepo.set(keyPath: \.credentials.guid, value: legacyRepoValue)
                                    return .just(legacyRepoValue)
                                }
                                .eraseToAnyPublisher()
                        }
                        return .just(guid)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func set(guid: String) -> AnyPublisher<Void, Never> {
        walletRepository.set(guid: guid)
            .zip(
                walletRepo.set(keyPath: \.credentials.guid, value: guid).get()
            )
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
