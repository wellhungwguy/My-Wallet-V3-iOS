// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol DelegatedCustodyAccountRepositoryAPI {

    var delegatedCustodyAccounts: AnyPublisher<[DelegatedCustodyAccount], Error> { get }
}
