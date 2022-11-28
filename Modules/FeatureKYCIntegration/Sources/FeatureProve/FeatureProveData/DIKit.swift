// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureProveDomain
import NetworkKit

extension DependencyContainer {

    // MARK: - FeatureProveData Module

    public static var featureProveData = module {

        // MARK: - Clients

        factory { () -> MobileAuthInfoClientAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            return MobileAuthInfoClient(networkAdapter: adapter, requestBuilder: builder)
        }

        factory { () -> FlowKYCInfoClientAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            return FlowKYCInfoClient(networkAdapter: adapter, requestBuilder: builder)
        }

        // MARK: - Repositories

        factory { () -> MobileAuthInfoRepositoryAPI in
            MobileAuthInfoRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> FlowKYCInfoRepositoryAPI in
            FlowKYCInfoRepository(
                client: DIKit.resolve()
            )
        }
    }
}
