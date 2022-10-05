// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitectureExtensions
import Dispatch
import FeatureSettingsDomain
import Localization

final class BlockchainDomainsCommonCellPresenter: CommonCellPresenting {
    var isLoading: Bool = true

    private let provider: BlockchainDomainsAdapter

    var subtitle: AnyPublisher<LoadingState<String>, Never> {
        provider
            .state
            .map(\.loadingState)
            .prepend(.loading)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] output in
                    self?.isLoading = output.isLoading
                }
            )
            .eraseToAnyPublisher()
    }

    init(provider: BlockchainDomainsAdapter) {
        self.provider = provider
    }
}

extension BlockchainDomainsAdapterState {
    var loadingState: LoadingState<String> {
        switch self {
        case .unavailable:
            return .loading
        case .domainsClaimed(let domains):
            return .loaded(next: "\(domains.count)")
        case .kycForClaimDomain:
            return .loaded(next: LocalizationConstants.Settings.cryptoDomainsClaim)
        case .readyToClaimDomain:
            return .loaded(next: LocalizationConstants.Settings.cryptoDomainsClaim)
        }
    }
}
