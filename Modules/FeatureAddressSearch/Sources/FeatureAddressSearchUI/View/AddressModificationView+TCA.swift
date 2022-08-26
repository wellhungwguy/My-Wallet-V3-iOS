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
    case didReceivePrefilledAddressResult(Result<Address?, AddressServiceError>)
    case updateAddressResponse(Result<Address, AddressServiceError>)
    case fetchAddressDetails(addressId: String?)
    case didReceiveAdressDetailsResult(Result<AddressDetailsSearchResult, AddressSearchServiceError>)
    case addressResponse(Result<Address, AddressServiceError>)
    case closeError
    case cancelEdit
    case showStateDoesNotMatchAlert
    case stateDoesNotMatch
    case showAlert(title: String, message: String)
    case dismissAlert
    case showGenericError
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
    @BindableState var stateName = ""
    @BindableState var postcode = ""
    @BindableState var country = ""
    @BindableState var selectedInputField: Field?

    var address: Address?
    var loading: Bool = false
    var addressDetailsId: String?
    var error: Nabu.Error?
    var isPresentedWithSearchView: Bool
    var screenTitle: String = ""
    var screenSubtitle: String?
    var saveButtonTitle: String?
    var isStateFieldVisible: Bool {
        address?.country == Address.Constants.usIsoCode
    }
    var failureAlert: AlertState<AddressModificationAction>?

    init(
        addressDetailsId: String? = nil,
        address: Address? = nil,
        isPresentedWithSearchView: Bool = true,
        error: Nabu.Error? = nil
    ) {
        self.addressDetailsId = addressDetailsId
        self.address = address
        self.isPresentedWithSearchView = isPresentedWithSearchView
        self.error = error

        state = address?
            .state?
            .replacingOccurrences(
                of: Address.Constants.usPrefix,
                with: ""
            ) ?? ""
        stateName = usaStates[state] ?? ""
        country = address?.country ?? ""

        if !isPresentedWithSearchView {
            line1 = address?.line1 ?? ""
            line2 = address?.line2 ?? ""
            city = address?.city ?? ""
            postcode = address?.postCode ?? ""
        }
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
        stateName = usaStates[state] ?? ""
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
        return .merge(
            Effect(value: .showGenericError),
            Effect(value: .addressResponse(result))
        )

    case .showGenericError:
        return Effect(
            value: .showAlert(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.AddressSearch.Form.Errors.genericError
            )
        )

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
            if let state = state.address?.state, state.isNotEmpty,
               state != address.state {
                return Effect(value: .showStateDoesNotMatchAlert)
            } else {
                state.address = address
                state.updateAddressInputs(address: address)
                return .none
            }

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
        state.saveButtonTitle = env.config.saveAddressButtonTitle

        guard let addressDetailsId = state.addressDetailsId else {
            if !state.isPresentedWithSearchView {
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
        guard let address = address else { return .none }
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

    case .showAlert(let title, let message):
        state.failureAlert = AlertState(
            title: TextState(verbatim: title),
            message: TextState(verbatim: message),
            dismissButton: .default(
                TextState(LocalizationConstants.okString),
                action: .send(.dismissAlert)
            )
        )
        return .none

    case .dismissAlert:
        state.failureAlert = nil
        return .none

    case .showStateDoesNotMatchAlert:
        let loc = LocalizationConstants.AddressSearch.Form.Errors.self
        state.failureAlert = AlertState(
            title: TextState(verbatim: loc.cannotEditStateTitle),
            message: TextState(verbatim: loc.cannotEditStateMessage),
            dismissButton: .default(
                TextState(LocalizationConstants.okString),
                action: .send(.stateDoesNotMatch)
            )
        )
        return .none
    case .stateDoesNotMatch:
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
        case .network(let error):
            return error
        }
    }
}

private let usaStates: [String: String] = [
    "AK": "Alaska",
    "AL": "Alabama",
    "AR": "Arkansas",
    "AS": "American Samoa",
    "AZ": "Arizona",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DC": "District of Columbia",
    "DE": "Delaware",
    "FL": "Florida",
    "GA": "Georgia",
    "GU": "Guam",
    "HI": "Hawaii",
    "IA": "Iowa",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "MA": "Massachusetts",
    "MD": "Maryland",
    "ME": "Maine",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MO": "Missouri",
    "MS": "Mississippi",
    "MT": "Montana",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "NE": "Nebraska",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NM": "New Mexico",
    "NV": "Nevada",
    "NY": "New York",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "OR": "Oregon",
    "PA": "Pennsylvania",
    "PR": "Puerto Rico",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VA": "Virginia",
    "VI": "Virgin Islands",
    "VT": "Vermont",
    "WA": "Washington",
    "WI": "Wisconsin",
    "WV": "West Virginia",
    "WY": "Wyoming"
]
