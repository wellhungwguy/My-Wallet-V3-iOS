// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol DelegatedCustodyActivityRepositoryAPI {

    func activity(
        for cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[DelegatedCustodyActivity], Error>
}
