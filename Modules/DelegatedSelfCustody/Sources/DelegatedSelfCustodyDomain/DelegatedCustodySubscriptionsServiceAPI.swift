// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol DelegatedCustodySubscriptionsServiceAPI {
    func subscribe() -> AnyPublisher<Void, Error>
}
