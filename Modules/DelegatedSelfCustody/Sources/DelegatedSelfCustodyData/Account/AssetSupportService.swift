// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain

final class AssetSupportService {

    private let app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }

    /// Stream collection of supported assets.
    func supportedDerivations() -> AnyPublisher<[DelegatedCustodyDerivation], Error> {
        app
            .publisher(
                for: blockchain.app.configuration.dynamicselfcustody.assets,
                as: DelegatedCustodyDerivationResponse.self
            )
            .prefix(1)
            .replaceError(with: .empty)
            .map { response in
                response.assets.map(DelegatedCustodyDerivation.init(response:))
            }
            .eraseError()
            .eraseToAnyPublisher()
    }
}
