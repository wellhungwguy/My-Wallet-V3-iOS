// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol MobileAuthInfoClientAPI {

    func getMobileAuthInfo(
    ) -> AnyPublisher<MobileAuthInfoResponse, NabuError>
}
