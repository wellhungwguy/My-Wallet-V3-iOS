// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import Errors
import FeatureAddressSearchDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

enum AddressModificationAction: Equatable, BindableAction {

    case onAppear
    case updateAddress
    case fetchPrefilledAddress
    case didReceivePrefilledAddressResult(Result<Address, AddressServiceError>)
    case updateAddressResponse(Result<Address, AddressServiceError>)
    case fetchAddressDetails(addressId: String?)
    case didReceiveAdressDetailsResult(Result<AddressDetailsSearchResult, AddressSearchServiceError>)
    case addressResponse(Result<Address, AddressServiceError>)
    case closeError
    case cancelEdit
    case binding(BindingAction<AddressModificationState>)
}

struct AddressModificationState: Equatable {

    enum Field: Equatable {
        case line1, line2, city, state, zip
    }

    @BindableState var line1 = ""
    @BindableState var line2 = ""
    @BindableState var city = ""
    @BindableState var state = ""
    @BindableState var postcode = ""
    @BindableState var country = ""
    @BindableState var selectedInputField: Field?

    var address: Address?
    var loading: Bool = false
    var addressDetailsId: String?
    var error: Nabu.Error?
    var isPresentedWithoutSearchView: Bool
    var screenTitle: String = ""
    var screenSubtitle: String?

    init(
        addressDetailsId: String? = nil,
        address: Address? = nil,
        isPresentedWithoutSearchView: Bool = false,
        error: Nabu.Error? = nil
    ) {
        self.addressDetailsId = addressDetailsId
        self.address = address
        self.isPresentedWithoutSearchView = isPresentedWithoutSearchView
        self.error = error
        line1 = address?.line1 ?? ""
        line2 = address?.line2 ?? ""
        city = address?.city ?? ""
        state = address?
            .state?
            .replacingOccurrences(
                of: Address.Constants.usPrefix,
                with: ""
            ) ?? ""
        postcode = address?.postCode ?? ""
        country = address?.country ?? ""
    }
}

extension AddressModificationState {
    fileprivate mutating func updateAddressInputs(address: Address) {
        selectedInputField = nil
        line1 = address.line1 ?? ""
        line2 = address.line2 ?? ""
        city = address.city ?? ""
        state = address
            .state?
            .replacingOccurrences(
                of: Address.Constants.usPrefix,
                with: ""
            ) ?? ""
        postcode = address.postCode ?? ""
        country = address.country ?? ""
    }
}

struct AddressModificationEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let config: AddressSearchFeatureConfig.AddressEditScreenConfig
    let addressService: AddressServiceAPI
    let addressSearchService: AddressSearchServiceAPI
    let onComplete: ((Address?) -> Void)?

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        config: AddressSearchFeatureConfig.AddressEditScreenConfig,
        addressService: AddressServiceAPI,
        addressSearchService: AddressSearchServiceAPI,
        onComplete: ((Address?) -> Void)? = nil
    ) {
        self.mainQueue = mainQueue
        self.config = config
        self.addressService = addressService
        self.addressSearchService = addressSearchService
        self.onComplete = onComplete
    }
}

let addressModificationReducer = Reducer<
    AddressModificationState,
    AddressModificationAction,
    AddressModificationEnvironment
> { state, action, env in

    switch action {
    case .updateAddress:
        state.loading = true
        return env
            .addressService
            .save(
                address: Address(
                    line1: state.line1,
                    line2: state.line2,
                    city: state.city,
                    postCode: state.postcode,
                    state: state.state,
                    country: state.country
                )
            )
            .receive(on: env.mainQueue)
            .catchToEffect(AddressModificationAction.updateAddressResponse)

    case .updateAddressResponse(let result):
        switch result {
        case .success(let address):
            env.onComplete?(address)
        case .failure(let error):
            state.error = error.nabuError
        }
        return Effect(value: .addressResponse(result))

    case .fetchAddressDetails(let addressId):
        guard let addressId = addressId else {
            return .none
        }
        state.loading = true
        return env
            .addressSearchService
            .fetchAddress(addressId: addressId)
            .receive(on: env.mainQueue)
            .catchToEffect()
            .map { result in
                .didReceiveAdressDetailsResult(result)
            }

    case .didReceiveAdressDetailsResult(let result):
        state.loading = false
        switch result {
        case .success(let searchedAddress):
            let address = Address(addressDetails: searchedAddress)
            state.address = address
            state.updateAddressInputs(address: address)
            return .none
        case .failure(let error):
            state.error = error.nabuError
            return .none
        }

    case .addressResponse(.success(let address)):
        state.loading = false
        state.updateAddressInputs(address: address)
        return .none

    case .addressResponse(.failure(let error)):
        state.loading = false
        state.error = error.nabuError
        return .none

    case .onAppear:
        state.screenTitle = env.config.title
        state.screenSubtitle = env.config.subtitle
        guard state.address == .none else {
            return .none
        }
        guard let addressDetailsId = state.addressDetailsId else {
            if state.isPresentedWithoutSearchView {
                return Effect(value: .fetchPrefilledAddress)
            } else {
                return .none
            }
        }
        return Effect(value: .fetchAddressDetails(addressId: addressDetailsId))

    case .fetchPrefilledAddress:
        return env
            .addressService
            .fetchAddress()
            .receive(on: env.mainQueue)
            .catchToEffect(AddressModificationAction.didReceivePrefilledAddressResult)

    case .didReceivePrefilledAddressResult(.success(let address)):
        state.address = address
        state.updateAddressInputs(address: address)
        return .none

    case .didReceivePrefilledAddressResult(.failure(let error)):
        state.loading = false
        state.error = error.nabuError
        return .none

    case .closeError:
        state.error = nil
        return .none

    case .cancelEdit:
        env.onComplete?(state.address)
        return .none

    case .binding:
        return .none
    }
}
.binding()

extension Address {
    fileprivate init(addressDetails: AddressDetailsSearchResult) {
        let line1 = [
            addressDetails.line1,
            addressDetails.line2,
            addressDetails.line3,
            addressDetails.line4,
            addressDetails.line5
        ]
            .compactMap { $0 }
            .filter(\.isNotEmpty)
            .joined(separator: ", ")
        self.init(
            line1: line1,
            line2: nil,
            city: addressDetails.city,
            postCode: addressDetails.postCode,
            state: addressDetails.state,
            country: addressDetails.country
        )
    }
}

extension AddressServiceError {
    var nabuError: Nabu.Error {
        switch self {
        case let .network(error):
            return error
        }
    }
}
