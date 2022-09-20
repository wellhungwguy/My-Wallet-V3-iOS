// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class LanguageRepository: LanguageRepositoryAPI {

    private let walletRepo: WalletRepoAPI

    init(
        walletRepo: WalletRepoAPI
    ) {
        self.walletRepo = walletRepo
    }

    func set(language: String) -> AnyPublisher<Void, Never> {
        Deferred { [walletRepo] in
            walletRepo.set(keyPath: \.properties.language, value: language)
                .get()
                .mapToVoid()
        }
        .eraseToAnyPublisher()
    }
}
