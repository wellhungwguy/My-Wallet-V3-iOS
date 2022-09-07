// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain

final class AssetSupportService {

    private let app: AppProtocol
    private let stacksSupport: DelegatedCustodyStacksSupportServiceAPI

    init(
        app: AppProtocol,
        stacksSupport: DelegatedCustodyStacksSupportServiceAPI
    ) {
        self.app = app
        self.stacksSupport = stacksSupport
    }

    /// Stream collection of supported assets.
    func supportedDerivations() -> AnyPublisher<[DelegatedCustodyDerivation], Error> {
        let assets = app
            .publisher(
                for: blockchain.app.configuration.dynamicselfcustody.assets,
                as: DelegatedCustodyDerivationResponse.self
            )
            .prefix(1)
            .replaceError(with: .empty)
            .map { response in
                response.assets.map(DelegatedCustodyDerivation.init(response:))
            }

        return assets
            .zip(stacksSupport.isEnabled)
            .eraseError()
            .map { (assets, stacksSupportIsEnabled) -> [DelegatedCustodyDerivation] in
                guard stacksSupportIsEnabled else {
                    return assets.filter { $0.currencyCode != "STX" }
                }
                return assets
            }
            .eraseToAnyPublisher()
    }
}
