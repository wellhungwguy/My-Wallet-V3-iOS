// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureActivityDomain
import FeatureCardPaymentDomain

// MARK: - Blockchain Module

extension DependencyContainer {

    static var blockchainActivity = module {
        factory { () -> ActivityCardDataServiceAPI in
            ActivityCardDataService(cardListService: DIKit.resolve())
        }
    }
}

final class ActivityCardDataService: ActivityCardDataServiceAPI {

    private let cardListService: CardListServiceAPI

    init(cardListService: CardListServiceAPI) {
        self.cardListService = cardListService
    }

    func fetchCardDisplayName(for paymentMethodId: String) -> AnyPublisher<String?, Never> {
        cardListService
            .card(by: paymentMethodId)
            .map { cardData in
                guard let cardData = cardData else {
                    return nil
                }
                return "\(cardData.label) \(cardData.displaySuffix)"
            }
            .eraseToAnyPublisher()
    }
}
