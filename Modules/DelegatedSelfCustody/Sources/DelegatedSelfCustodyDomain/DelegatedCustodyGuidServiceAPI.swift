// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// Needs to be injected from consumer.
public protocol DelegatedCustodyGuidServiceAPI: AnyObject {
    /// Streams wallet guid.
    var guid: AnyPublisher<String?, Never> { get }
}
