// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Errors
import Foundation
import MoneyKit

public protocol ReferralServiceAPI {
    func fetchReferralCampaign() -> AnyPublisher<Referral?, Never>
    func createReferral(with code: String) -> AnyPublisher<Void, NetworkError>
}

public class ReferralService: ReferralServiceAPI {
    private let repository: ReferralRepositoryAPI
    private let app: AppProtocol

    public init(
        app: AppProtocol,
        repository: ReferralRepositoryAPI
    ) {
        self.app = app
        self.repository = repository
    }

    public func createReferral(with code: String) -> AnyPublisher<Void, NetworkError> {
        repository
            .createReferral(with: code)
            .eraseToAnyPublisher()
    }

    public func fetchReferralCampaign() -> AnyPublisher<Referral?, Never> {
        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .flatMap { [repository] currency in
                repository.fetchReferralCampaign(for: currency.code)
            }
            .optional()
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
