// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class GuidRepository: GuidRepositoryAPI {

    let guid: AnyPublisher<String?, Never>

    private let legacyGuidRepository: LegacyGuidRepositoryAPI
    private let walletRepo: WalletRepoAPI

    init(
        legacyGuidRepository: LegacyGuidRepositoryAPI,
        walletRepo: WalletRepoAPI
    ) {
        self.legacyGuidRepository = legacyGuidRepository
        self.walletRepo = walletRepo

        guid = Deferred { [walletRepo, legacyGuidRepository] in
            walletRepo
                .get()
                .map(\.credentials.guid)
                .flatMap { guid -> AnyPublisher<String?, Never> in
                    guard !guid.isEmpty else {
                        return legacyGuidRepository.guid
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
        }
        .eraseToAnyPublisher()
    }

    func set(guid: String) -> AnyPublisher<Void, Never> {
        Deferred { [legacyGuidRepository, walletRepo] in
            legacyGuidRepository.set(guid: guid)
                .zip(
                    walletRepo.set(keyPath: \.credentials.guid, value: guid).get()
                )
                .mapToVoid()
        }
        .eraseToAnyPublisher()
    }
}
