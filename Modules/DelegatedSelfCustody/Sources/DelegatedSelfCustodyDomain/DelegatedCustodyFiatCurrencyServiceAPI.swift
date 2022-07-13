// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

/// Needs to be injected from consumer.
public protocol DelegatedCustodyFiatCurrencyServiceAPI: AnyObject {
    /// Streams current active/default FiatCurrency
    var fiatCurrency: AnyPublisher<FiatCurrency, Never> { get }
}
