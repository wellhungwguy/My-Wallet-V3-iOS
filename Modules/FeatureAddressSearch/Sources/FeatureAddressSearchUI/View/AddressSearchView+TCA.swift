// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import ComposableNavigation
import Errors
import FeatureAddressSearchDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

enum AddressSearchAction: Equatable, BindableAction, NavigationAction {

    case onAppear
    case route(RouteIntent<AddressSearchRoute>?)
    case searchAddresses(searchText: String?, containerId: String?, country: String?)
    case didReceiveAddressesResult(Result<[AddressSearchResult], AddressSearchServiceError>)
    case selectAddress(AddressSearchResult)
    case modifySelectedAddress(addressId: String?)
    case modifyAddress
    case updateSelectedAddress(Address)
    case addressModificationAction(AddressModificationAction)
    case closeError
    case cancelSearch
    case binding(BindingAction<AddressSearchState>)
}

enum SearchAddressId {
    struct SearchDebounceId: Hashable {}
}

struct AddressSearchState: Equatable, NavigationState {

    @BindableState var searchText: String = ""
    @BindableState var isSearchFieldSelected: Bool = false
    var isSearchResultsLoading: Bool = false
    var searchResults: [AddressSearchResult] = []
    var isAddressSearchResultsNotFoundVisible: Bool {
        searchText.isNotEmpty && searchResults.isEmpty && !isSearchResultsLoading
    }

    var address: Address?
    var route: RouteIntent<AddressSearchRoute>?
    var addressModificationState: AddressModificationState?
    var isAddressModificationVisible = false
    var loading = false
    var screenTitle: String = ""
    var error: Nabu.Error?

    init(
        address: Address? = nil,
        error: Nabu.Error? = nil
    ) {
        self.address = address
        self.error = error
        self.route = nil
        self.searchText = address?.searchText ?? ""
    }
}

struct AddressSearchEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let config: AddressSearchFeatureConfig
    let addressService: AddressServiceAPI
    let addressSearchService: AddressSearchServiceAPI
    let onComplete: (Address?) -> Void

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        config: AddressSearchFeatureConfig,
        addressService: AddressServiceAPI,
        addressSearchService: AddressSearchServiceAPI,
        onComplete: @escaping (Address?) -> Void
    ) {
        self.mainQueue = mainQueue
        self.config = config
        self.addressService = addressService
        self.addressSearchService = addressSearchService
        self.onComplete = onComplete
    }
}

let addressSearchReducer = Reducer.combine(
    addressModificationReducer.optional().pullback(
        state: \.addressModificationState,
        action: /AddressSearchAction.addressModificationAction,
        environment: {
            AddressModificationEnvironment(
                mainQueue: $0.mainQueue,
                config: $0.config.addressEditScreen,
                addressService: $0.addressService,
                addressSearchService: $0.addressSearchService
            )
        }
    ),
    Reducer<
        AddressSearchState,
        AddressSearchAction,
        AddressSearchEnvironment
    > { state, action, env in

        switch action {
        case .binding(\.$searchText):
            return Effect(
                value: .searchAddresses(
                    searchText: state.searchText, containerId: nil, country: state.address?.country
                )
            )

        case let .selectAddress(searchAddressResult):
            if searchAddressResult.isAddressType {
                return Effect(value: .modifySelectedAddress(addressId: searchAddressResult.addressId))
            } else {
                state.searchText = (searchAddressResult.text ?? "") + " "
                return Effect(
                    value: .searchAddresses(
                        searchText: state.searchText,
                        containerId: searchAddressResult.addressId,
                        country: state.address?.country
                    )
                )
            }

        case let .modifySelectedAddress(addressId):
            return Effect(
                value: .navigate(to: .modifyAddress(selectedAddressId: addressId, address: nil))
            )

        case .modifyAddress:
            return Effect(
                value: .navigate(to: .modifyAddress(selectedAddressId: nil, address: state.address))
            )

        case .onAppear:
            state.screenTitle = env.config.addressSearchScreen.title
            guard state.address == .none else {
                if state.searchResults.isEmpty {
                    return Effect(
                        value: .searchAddresses(
                            searchText: state.address?.searchText,
                            containerId: nil,
                            country: state.address?.country
                        )
                    )
                } else {
                    return .none
                }
            }
            return .none

        case .route(let route):
            if let routeValue = route?.route {
                switch routeValue {
                case let .modifyAddress(selectedAddressId, address):
                    state.addressModificationState = .init(
                        addressDetailsId: selectedAddressId,
                        address: address
                    )
                    state.route = route
                }
            } else {
                state.addressModificationState = nil
                state.route = route
            }
            return .none

        case .closeError:
            state.error = nil
            return .none

        case .binding:
            return .none

        case let .updateSelectedAddress(address):
            state.address = address
            return Effect(value: .cancelSearch)

        case .cancelSearch:
            env.onComplete(state.address)
            return .none

        case let .searchAddresses(searchText, containerId, country):
            guard let searchText = searchText, searchText.isNotEmpty,
                  let country = country, country.isNotEmpty else {
                state.searchResults = []
                return .none
            }
            state.isSearchResultsLoading = true
            return env
                .addressSearchService
                .fetchAddresses(searchText: searchText, containerId: containerId, countryCode: country)
                .receive(on: env.mainQueue)
                .catchToEffect()
                .debounce(
                    id: SearchAddressId.SearchDebounceId(),
                    for: .milliseconds(500),
                    scheduler: env.mainQueue
                )
                .map { result in
                    .didReceiveAddressesResult(result)
                }

        case .didReceiveAddressesResult(let result):
            state.isSearchResultsLoading = false
            switch result {
            case .success(let searchedAddresses):
                state.searchResults = searchedAddresses
            case .failure(let error):
                print(error)
            }
            return .none

        case let .addressModificationAction(modificationAction):
            switch modificationAction {
            case let .updateAddressResponse(.success(address)):
                state.address = address
                state.isAddressModificationVisible = false
                return .merge(
                    Effect(value: .dismiss()),
                    Effect(value: .updateSelectedAddress(address))
                )
            case .cancelEdit:
                env.onComplete(state.address)
                return .none
            default:
                return .none
            }
        }
    }
    .binding()
)

extension Address {
    fileprivate var searchText: String {
        let state = state?.replacingOccurrences(
            of: Address.Constants.usPrefix,
            with: ""
        ) ?? ""
        return [
            postCode,
            line1,
            line2,
            city,
            state
        ]
            .compactMap { $0 }
            .filter(\.isNotEmpty)
            .joined(separator: " ")
    }
}

extension AddressSearchServiceError {
    var nabuError: Nabu.Error {
        switch self {
        case let .network(error):
            return error
        }
    }
}

#if DEBUG

struct MockServices: AddressSearchServiceAPI {

    static let addressId = "GB|RM|B|27354762"

    static let address = Address(
        line1: "614 Lorimer Street",
        line2: nil,
        city: "",
        postCode: "11111",
        state: "CA",
        country: "US"
    )

    func fetchAddresses(
        searchText: String,
        containerId: String?,
        countryCode: String
    ) -> AnyPublisher<[AddressSearchResult], AddressSearchServiceError> {
        .just([])
    }

    func fetchAddress(addressId: String) -> AnyPublisher<AddressDetailsSearchResult, AddressSearchServiceError> {
        .just(
            .init(
                addressId: "GB|TS|A|2966",
                line1: "32 Evergreen Boulevard",
                street: "Evergreen Boulevard",
                buildingNumber: "32",
                city: "Gotham City",
                postCode: "89109-1234",
                state: "Arizona",
                stateCode: nil,
                country: "US",
                label: "32 Evergreen Boulevard \nGOTHAM CITY\n89109-1234\nUNITED STATES"
            )
        )
    }
}

extension MockServices: AddressServiceAPI {
    func save(address: Address) -> AnyPublisher<Address, AddressServiceError> {
        .just(Self.address)
    }
    func fetchAddress() -> AnyPublisher<Address, AddressServiceError> {
        .just(Self.address)
    }
}
#endif
