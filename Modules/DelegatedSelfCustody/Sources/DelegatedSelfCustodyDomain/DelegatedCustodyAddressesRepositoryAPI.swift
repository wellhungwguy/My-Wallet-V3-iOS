// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol DelegatedCustodyAddressesRepositoryAPI {
    func addresses(for cryptoCurrency: CryptoCurrency) -> AnyPublisher<[DelegatedCustodyAddress], Error>
}
