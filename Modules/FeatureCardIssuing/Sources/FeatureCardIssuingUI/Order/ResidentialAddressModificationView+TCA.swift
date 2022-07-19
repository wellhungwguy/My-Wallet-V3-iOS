// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import Errors
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

enum ResidentialAddressModificationAction: Equatable, BindableAction {

    case onAppear
    case updateAddress
    case updateAddressResponse(Result<Card.Address, NabuNetworkError>)
    case addressResponse(Result<Card.Address, NabuNetworkError>)
    case closeError
    case binding(BindingAction<ResidentialAddressModificationState>)
}

struct ResidentialAddressModificationState: Equatable {

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

    var address: Card.Address?
    var loading = false
    var error: NabuNetworkError?

    init(
        address: Card.Address? = nil,
        error: NabuNetworkError? = nil
    ) {
        self.address = address
        self.error = error
        line1 = address?.line1 ?? ""
        line2 = address?.line2 ?? ""
        city = address?.city ?? ""
        state = address?
            .state?
            .replacingOccurrences(
                of: Card.Address.Constants.usPrefix,
                with: ""
            ) ?? ""
        postcode = address?.postCode ?? ""
        country = address?.country ?? ""
    }
}

// swiftlint:disable type_name
struct ResidentialAddressModificationEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let residentialAddressService: ResidentialAddressServiceAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        residentialAddressService: ResidentialAddressServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.residentialAddressService = residentialAddressService
    }
}

let residentialAddressModificationReducer = Reducer<
    ResidentialAddressModificationState,
    ResidentialAddressModificationAction,
    ResidentialAddressModificationEnvironment
> { state, action, env in

    switch action {
    case .updateAddress:
        state.loading = true
        return env
            .residentialAddressService
            .update(
                residentialAddress: Card.Address(
                    line1: state.line1,
                    line2: state.line2,
                    city: state.city,
                    postCode: state.postcode,
                    state: state.state,
                    country: state.country
                )
            )
            .receive(on: env.mainQueue)
            .catchToEffect(ResidentialAddressModificationAction.updateAddressResponse)
    case .updateAddressResponse(let result):
        return Effect(value: .addressResponse(result))
    case .addressResponse(.success(let address)):
        state.selectedInputField = nil
        state.address = address
        state.loading = false
        state.line1 = address.line1 ?? ""
        state.line2 = address.line2 ?? ""
        state.city = address.city ?? ""
        state.state = address
            .state?
            .replacingOccurrences(
                of: Card.Address.Constants.usPrefix,
                with: ""
            ) ?? ""
        state.postcode = address.postCode ?? ""
        state.country = address.country ?? ""
        return .none
    case .addressResponse(.failure(let error)):
        state.loading = false
        state.error = error
        return .none
    case .onAppear:
        guard state.address == .none else {
            return .none
        }
        state.loading = true
        return env.residentialAddressService
            .fetchResidentialAddress()
            .receive(on: env.mainQueue)
            .catchToEffect(ResidentialAddressModificationAction.addressResponse)
    case .closeError:
        state.error = nil
        return .none
    case .binding:
        return .none
    }
}
.binding()
