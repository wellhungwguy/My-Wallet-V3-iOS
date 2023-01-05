// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestDomain
import Localization
import MoneyKit
import PlatformKit
import ToolKit

struct InterestNoEligibleWalletsState: Equatable {

    // MARK: - Private Types

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.NoEligibleWallets

    // MARK: - Public Properties

    var title: String {
        String(format: LocalizationId.title, code)
    }

    var description: String {
        String(
            format: LocalizationId.description,
            code,
            code,
            "\(interestRate.string(with: 1))%",
            name
        )
    }

    var action: String {
        String(format: LocalizationId.action, code)
    }

    let interestRate: Double
    let cryptoCurrency: CryptoCurrency
    var isRoutingToBuy: Bool

    // MARK: - Private Properites

    private var name: String {
        cryptoCurrency.name
    }

    private var code: String {
        cryptoCurrency.code
    }

    // MARK: - Init

    init(interestAccountRate: InterestAccountRate) {
        self.isRoutingToBuy = false
        self.interestRate = interestAccountRate.rate
        self.cryptoCurrency = interestAccountRate.cryptoCurrency
    }
}
