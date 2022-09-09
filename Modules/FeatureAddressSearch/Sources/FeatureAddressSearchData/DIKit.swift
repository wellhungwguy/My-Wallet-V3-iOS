import Combine
import DIKit
import FeatureAddressSearchDomain
import NetworkKit

extension DependencyContainer {

    // MARK: - FeatureAddressSearchData Module

    public static var featureAddressSearchData = module {

        factory {
            AddressSearchRepository(
                client: AddressSearchClient(
                    networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                    requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
                )
            ) as AddressSearchRepositoryAPI
        }
    }
}
