// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

final class CardSuccessRateService: CardSuccessRateServiceAPI {

    private let repository: CardSuccessRateRepositoryAPI

    init(repository: CardSuccessRateRepositoryAPI) {
        self.repository = repository
    }

    // MARK: - CardSuccessRateServiceAPI

    func getCardSuccessRate(
        binNumber: String
    ) -> AnyPublisher<CardSuccessRateData, CardSuccessRateServiceError> {
        repository
            .getCardSuccessRate(binNumber: binNumber)
            .mapError(CardSuccessRateServiceError.nabu)
            .eraseToAnyPublisher()
    }
}
