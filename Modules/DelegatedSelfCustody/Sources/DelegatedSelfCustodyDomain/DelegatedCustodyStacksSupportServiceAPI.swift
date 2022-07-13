// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// Needs to be injected from consumer.
public protocol DelegatedCustodyStacksSupportServiceAPI {
    var isEnabled: AnyPublisher<Bool, Never> { get }
}
