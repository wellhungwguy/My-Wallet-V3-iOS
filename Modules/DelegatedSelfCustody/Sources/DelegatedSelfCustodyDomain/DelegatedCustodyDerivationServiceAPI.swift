// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

/// Needs to be injected from consumer.
public protocol DelegatedCustodyDerivationServiceAPI {
    /// Streams public and private keys for deriving the default HDWallet on the given derivation path.
    func getKeys(
        path: String
    ) -> AnyPublisher<(publicKey: Data, privateKey: Data), Error>
}
