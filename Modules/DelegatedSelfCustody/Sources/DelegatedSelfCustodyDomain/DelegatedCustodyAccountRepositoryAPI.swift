// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol DelegatedCustodyAccountRepositoryAPI {

    func accountsCurrencies() -> AnyPublisher<[CryptoCurrency], Error>
}
