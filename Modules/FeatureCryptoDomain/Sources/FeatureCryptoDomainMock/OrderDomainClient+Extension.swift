// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG
@testable import FeatureCryptoDomainData
import Foundation
import NetworkKit

extension OrderDomainClient {

    static let mock = OrderDomainClient(
        networkAdapter: NetworkAdapter(
            communicator: EphemeralNetworkCommunicator(session: .shared)
        ),
        requestBuilder: RequestBuilder(
            config: Network.Config(
                scheme: "https",
                host: "api.staging.blockchain.info",
                components: ["nabu-gateway"]
            ),
            headers: ["Authorization": "Bearer Token"]
        )
    )

    public static func test(
        _ requests: [URLRequest: Data] = [:]
    ) -> (
        client: OrderDomainClient,
        communicator: ReplayNetworkCommunicator
    ) {
        let communicator = ReplayNetworkCommunicator(requests, in: Bundle.module)
        return (
            OrderDomainClient(
                networkAdapter: NetworkAdapter(
                    communicator: communicator
                ),
                requestBuilder: RequestBuilder(
                    config: Network.Config(
                        scheme: "https",
                        host: "api.staging.blockchain.info",
                        components: ["nabu-gateway"]
                    ),
                    headers: ["Authorization": "Bearer Token"]
                )
            ),
            communicator
        )
    }
}
#endif
