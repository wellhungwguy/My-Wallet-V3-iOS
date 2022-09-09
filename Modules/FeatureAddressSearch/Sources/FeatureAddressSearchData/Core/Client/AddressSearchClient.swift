// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureAddressSearchDomain
import Foundation
import NetworkKit

final class AddressSearchClient: AddressSearchClientAPI {

    // MARK: - Types

    private enum Path: String {
        case searchAddress = "address-capture/find"
        case retrieveAddress = "address-capture/retrieve"
    }

    private enum Parameter {
        static let text = "text"
        static let countryCode = "country_code"
        static let sateCode = "province_code"
        static let addressId = "id"
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - API

    func fetchAddresses(
        searchText: String,
        containerId: String?,
        countryCode: String,
        sateCode: String?
    ) -> AnyPublisher<[AddressSearchResult], Nabu.Error> {
        var parameters = [
            URLQueryItem(
                name: Parameter.text,
                value: searchText
            ),
            URLQueryItem(
                name: Parameter.countryCode,
                value: countryCode
            )
        ]
        if let containerId = containerId {
            parameters.append(
                URLQueryItem(
                    name: Parameter.addressId,
                    value: containerId
                )
            )
        }
        if let sateCode = sateCode {
            parameters.append(
                URLQueryItem(
                    name: Parameter.sateCode,
                    value: sateCode
                )
            )
        }

        let request = requestBuilder.get(
            path: [Path.searchAddress.rawValue],
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: AddressesSearchResult.self)
            .map(\.addresses)
            .eraseToAnyPublisher()
    }

    func fetchAddress(
        addressId: String
    ) -> AnyPublisher<AddressDetailsSearchResult, Nabu.Error> {
        let parameters = [
            URLQueryItem(
                name: Parameter.addressId,
                value: addressId
            )
        ]

        let request = requestBuilder.get(
            path: [Path.retrieveAddress.rawValue],
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: AddressDetailsSearchResult.self)
            .eraseToAnyPublisher()
    }
}

private struct AddressesSearchResult: Codable, Equatable {
    let addresses: [AddressSearchResult]
}
