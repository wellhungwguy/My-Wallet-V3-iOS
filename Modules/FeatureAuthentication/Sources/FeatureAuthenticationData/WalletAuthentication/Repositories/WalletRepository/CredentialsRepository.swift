// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class CredentialsRepository: CredentialsRepositoryAPI {

    let guid: AnyPublisher<String?, Never>
    let sharedKey: AnyPublisher<String?, Never>

    private let guidRepository: GuidRepositoryAPI
    private let sharedKeyRepository: SharedKeyRepositoryAPI

    init(
        guidRepository: GuidRepositoryAPI,
        sharedKeyRepository: SharedKeyRepositoryAPI
    ) {
        self.guidRepository = guidRepository
        self.sharedKeyRepository = sharedKeyRepository

        self.guid = guidRepository
            .guid

        self.sharedKey = sharedKeyRepository
            .sharedKey
    }

    // MARK: - GuidRepositoryAPI

    func set(guid: String) -> AnyPublisher<Void, Never> {
        guidRepository.set(guid: guid)
    }

    // MARK: - SharedKeyRepositoryAPI

    func set(sharedKey: String) -> AnyPublisher<Void, Never> {
        sharedKeyRepository.set(sharedKey: sharedKey)
    }
}
