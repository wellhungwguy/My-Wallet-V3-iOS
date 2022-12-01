// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAddressSearchDomain
import FeatureAddressSearchUI
import FeatureProveDomain
import FeatureProveUI
import Localization

final class AddressSearchFlowPresenterProveAdapter: FeatureProveUI.AddressSearchFlowPresenterAPI {

    private let addressSearchRouterRouter: FeatureAddressSearchDomain.AddressSearchRouterAPI

    init(
        addressSearchRouterRouter: FeatureAddressSearchDomain.AddressSearchRouterAPI
    ) {
        self.addressSearchRouterRouter = addressSearchRouterRouter
    }

    func openSearchAddressFlow(
        country: String,
        state: String?
    ) -> AnyPublisher<FeatureProveUI.AddressSearchResult, Never> {
        typealias Localization = LocalizationConstants.NewKYC.AddressProve
        let title = Localization.title
        return addressSearchRouterRouter.presentSearchAddressFlow(
            prefill: .init(state: state, country: country),
            config: .init(
                addressSearchScreen: .init(title: title),
                addressEditScreen: .init(
                    title: title,
                    saveAddressButtonTitle: Localization.continueButtonTitle,
                    shouldSaveAddressOnCompletion: false
                )
            )
        )
        .map { FeatureProveUI.AddressSearchResult(addressResult: $0) }
        .eraseToAnyPublisher()
    }

    func openEditAddressFlow(
        address: FeatureProveDomain.Address
    ) -> AnyPublisher<FeatureProveUI.AddressSearchResult, Never> {
        typealias Localization = LocalizationConstants.NewKYC.AddressProve
        let title = Localization.title
        return addressSearchRouterRouter.presentEditAddressFlow(
            address: .init(address: address),
            config: .init(
                title: title,
                saveAddressButtonTitle: Localization.continueButtonTitle,
                shouldSaveAddressOnCompletion: false
            )
        )
        .map { FeatureProveUI.AddressSearchResult(addressResult: $0) }
        .eraseToAnyPublisher()
    }
}

extension FeatureProveUI.AddressSearchResult {
    fileprivate init(addressResult: AddressResult) {
        switch addressResult {
        case .saved(let address):
            self = .saved(.init(address: address))
        case .abandoned:
            self = .abandoned
        }
    }
}

extension FeatureProveDomain.Address {
    fileprivate init(address: FeatureAddressSearchDomain.Address) {
        self.init(
            line1: address.line1,
            line2: address.line2,
            city: address.city,
            postCode: address.postCode,
            state: address.state,
            country: address.country
        )
    }
}

extension FeatureAddressSearchDomain.Address {
    fileprivate init(address: FeatureProveDomain.Address) {
        self.init(
            line1: address.line1,
            line2: address.line2,
            city: address.city,
            postCode: address.postCode,
            state: address.state,
            country: address.country
        )
    }
}
