// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG
@testable import FeatureCryptoDomainData
import Foundation
import NetworkKit

extension SearchDomainClient {

    static let mock = SearchDomainClient(
        networkAdapter: NetworkAdapter(
            communicator: EphemeralNetworkCommunicator(session: .shared)
        ),
        requestBuilder: RequestBuilder(
            config: Network.Config(
                scheme: "https",
                host: "api.staging.blockchain.info"
            )
        )
    )

    public static func test(
        _ requests: [URLRequest: Data] = [:]
    ) -> (
        client: SearchDomainClient,
        communicator: ReplayNetworkCommunicator
    ) {
        let communicator = ReplayNetworkCommunicator(requests, in: Bundle.module)
        return (
            SearchDomainClient(
                networkAdapter: NetworkAdapter(
                    communicator: communicator
                ),
                requestBuilder: RequestBuilder(
                    config: Network.Config(
                        scheme: "https",
                        host: "api.staging.blockchain.info"
                    )
                )
            ),
            communicator
        )
    }
}
#endif
