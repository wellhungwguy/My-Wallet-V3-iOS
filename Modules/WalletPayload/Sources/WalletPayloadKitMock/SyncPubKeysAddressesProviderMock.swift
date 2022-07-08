// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

class SyncPubKeysAddressesProviderMock: SyncPubKeysAddressesProviderAPI {

    var provideAddressesCalled = false
    var provideAddressesResult = Result<String, SyncPubKeysAddressesProviderError>.success("")

    func provideAddresses(
        active: [String],
        accounts: [Account]
    ) -> AnyPublisher<String, SyncPubKeysAddressesProviderError> {
        provideAddressesCalled = true
        return provideAddressesResult
            .publisher
            .eraseToAnyPublisher()
    }
}
