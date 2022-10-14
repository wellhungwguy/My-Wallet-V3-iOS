// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCardPaymentDomain
import PlatformKit
import ToolKit

extension PaymentMethodRemovalData {

    init(cardData: CardData) {
        self.init(
            id: cardData.identifier,
            title: cardData.type.name,
            description: "•••• \(cardData.suffix)",
            event: .sbRemoveCard,
            type: .card(cardData.type)
        )
    }

    init(beneficiary: Beneficiary) {
        self.init(
            id: beneficiary.identifier,
            title: beneficiary.name,
            description: beneficiary.account,
            event: .sbRemoveBank,
            type: .beneficiary(beneficiary.type),
            icon: beneficiary.icon
        )
    }
}
