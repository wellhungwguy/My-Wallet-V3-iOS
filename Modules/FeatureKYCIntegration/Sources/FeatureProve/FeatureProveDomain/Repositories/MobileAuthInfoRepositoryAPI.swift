// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol MobileAuthInfoRepositoryAPI {

    func getMobileAuthInfo() -> AnyPublisher<MobileAuthInfo, NabuError>
}
