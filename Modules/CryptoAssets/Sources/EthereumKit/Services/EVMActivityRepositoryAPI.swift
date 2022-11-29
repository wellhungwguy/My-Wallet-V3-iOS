// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol EVMActivityRepositoryAPI {

    func transactions(
        network: EVMNetwork,
        cryptoCurrency: CryptoCurrency,
        address: String
    ) -> AnyPublisher<[EVMHistoricalTransaction], Error>
}

extension EVMActivityRepositoryAPI {

    public func transactions(
        network: EVMNetwork,
        cryptoCurrency: CryptoCurrency,
        address: EthereumAddress
    ) -> AnyPublisher<[EVMHistoricalTransaction], Error> {
        transactions(
            network: network,
            cryptoCurrency: cryptoCurrency,
            address: address.publicKey
        )
    }
}
