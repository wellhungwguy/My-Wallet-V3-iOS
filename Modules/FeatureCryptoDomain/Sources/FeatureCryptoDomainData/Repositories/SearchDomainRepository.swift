// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCryptoDomainDomain
import Foundation

public final class SearchDomainRepository: SearchDomainRepositoryAPI {

    // MARK: - Properties

    private let apiClient: SearchDomainClientAPI
    private let queue = DispatchQueue(label: "SearchDomainRepository")

    // MARK: - Setup

    public init(apiClient: SearchDomainClientAPI) {
        self.apiClient = apiClient
    }

    public func searchResults(searchKey: String) -> AnyPublisher<[SearchDomainResult], SearchDomainRepositoryError> {
        apiClient
            .getSearchResults(searchKey: searchKey)
            .map { response in
                let searchedDomain = SearchDomainResult(from: response.searchedDomain)
                let suggestions = response.suggestions.map(SearchDomainResult.init)
                return [searchedDomain] + suggestions
            }
            .mapError(SearchDomainRepositoryError.networkError)
            .eraseToAnyPublisher()
    }
}
