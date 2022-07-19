// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// Needs to be injected from consumer.
public protocol DelegatedCustodySharedKeyServiceAPI: AnyObject {
    /// Streams shared key.
    var sharedKey: AnyPublisher<String?, Never> { get }
}
