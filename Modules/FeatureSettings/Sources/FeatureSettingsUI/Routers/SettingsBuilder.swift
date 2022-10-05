// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCardPaymentDomain
import Localization
import PlatformKit
import UIKit

protocol SettingsBuilding: AnyObject {
    func removeCardPaymentMethodViewController(cardData: CardData) -> UIViewController
    func removeBankPaymentMethodViewController(beneficiary: Beneficiary) -> UIViewController
}

final class SettingsBuilder: SettingsBuilding {

    private let cardDeletionService: PaymentMethodDeletionServiceAPI
    private let beneficiariesService: BeneficiariesServiceAPI

    init(
        cardDeletionService: PaymentMethodDeletionServiceAPI = resolve(),
        beneficiariesService: BeneficiariesServiceAPI = resolve()
    ) {
        self.cardDeletionService = cardDeletionService
        self.beneficiariesService = beneficiariesService
    }

    /// Generate remove card payment method view controller
    /// - Parameter cardData: CC data
    /// - Returns: The view controller
    func removeCardPaymentMethodViewController(cardData: CardData) -> UIViewController {
        let data = PaymentMethodRemovalData(cardData: cardData)
        return removePaymentMethodViewController(
            buttonLocalizedString: LocalizationConstants.Settings.Card.remove,
            removalData: data,
            deletionService: cardDeletionService
        )
    }

    /// Generate remove bank payment method view controller
    /// - Parameter cardData: Bank data
    /// - Returns: The view controller
    func removeBankPaymentMethodViewController(beneficiary: Beneficiary) -> UIViewController {
        let data = PaymentMethodRemovalData(beneficiary: beneficiary)
        return removePaymentMethodViewController(
            buttonLocalizedString: LocalizationConstants.Settings.Bank.remove,
            removalData: data,
            deletionService: beneficiariesService
        )
    }

    private func removePaymentMethodViewController(
        buttonLocalizedString: String,
        removalData: PaymentMethodRemovalData,
        deletionService: PaymentMethodDeletionServiceAPI
    ) -> UIViewController {
        let interactor = RemovePaymentMethodScreenInteractor(
            data: removalData,
            deletionService: deletionService
        )
        let presenter = RemovePaymentMethodScreenPresenter(
            buttonLocalizedString: buttonLocalizedString,
            interactor: interactor
        )
        let viewController = RemovePaymentMethodViewController(presenter: presenter)
        return viewController
    }
}
