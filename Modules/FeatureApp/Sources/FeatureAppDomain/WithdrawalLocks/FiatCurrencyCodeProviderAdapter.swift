// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureWithdrawalLocksDomain
import Foundation
import MoneyKit

final class FiatCurrencyCodeProviderAdapter: FiatCurrencyCodeProviderAPI {

    lazy var defaultFiatCurrencyCode: AnyPublisher<String, Never> = fiatCurrencyPublisher.displayCurrencyPublisher
        .map(\.code)
        .eraseToAnyPublisher()

    private let fiatCurrencyPublisher: FiatCurrencyServiceAPI

    init(fiatCurrencyPublisher: FiatCurrencyServiceAPI) {
        self.fiatCurrencyPublisher = fiatCurrencyPublisher
    }
}
