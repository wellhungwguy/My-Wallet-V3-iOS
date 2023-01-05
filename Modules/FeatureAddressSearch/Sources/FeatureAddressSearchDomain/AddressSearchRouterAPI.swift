// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol AddressSearchRouterAPI {

    func presentSearchAddressFlow(
        prefill: Address?,
        config: AddressSearchFeatureConfig
    ) -> AnyPublisher<AddressResult, Never>

    func presentEditAddressFlow(
        isPresentedFromSearchView: Bool,
        config: AddressSearchFeatureConfig.AddressEditScreenConfig
    ) -> AnyPublisher<AddressResult, Never>

    func presentEditAddressFlow(
        address: Address,
        config: AddressSearchFeatureConfig.AddressEditScreenConfig
    ) -> AnyPublisher<AddressResult, Never>
}
