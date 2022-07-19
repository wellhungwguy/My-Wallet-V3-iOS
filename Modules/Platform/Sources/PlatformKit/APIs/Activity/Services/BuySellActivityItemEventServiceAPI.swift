// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol BuySellActivityItemEventServiceAPI: AnyObject {
    func buySellActivityEvents(
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[BuySellActivityItemEvent], OrdersServiceError>
}
