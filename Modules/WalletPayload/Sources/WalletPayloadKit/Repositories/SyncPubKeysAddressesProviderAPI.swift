// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation

public enum SyncPubKeysAddressesProviderError: Error {
    case failureProvidingAddresses
}

public protocol SyncPubKeysAddressesProviderAPI {
    /// Provides all of the wallet active addresses, hd in a formatted string of `{address}|{address}...`
    func provideAddresses(
        active: [String],
        accounts: [Account]
    ) -> AnyPublisher<String, SyncPubKeysAddressesProviderError>
}
