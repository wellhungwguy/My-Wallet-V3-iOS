// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import Foundation
import MoneyKit
import ToolKit

final class CardActivationService: CardActivationServiceAPI {

    // MARK: - Injected

    private let client: CardDetailClientAPI

    // MARK: - Setup

    init(client: CardDetailClientAPI = resolve()) {
        self.client = client
    }

    func waitForActivation(
        of cardId: String
    ) -> AnyPublisher<Result<CardActivationState, CardActivationServiceError>, Never> {
        client.getCard(by: cardId)
            .map { payload in
                guard payload.state != .pending else {
                    return .pending
                }
                return CardActivationState(payload)
            }
            .mapError(CardActivationServiceError.nabu)
            .poll(max: 40, until: { !$0.isPending }, delay: .seconds(3))
            .mapToResult()
    }
}
