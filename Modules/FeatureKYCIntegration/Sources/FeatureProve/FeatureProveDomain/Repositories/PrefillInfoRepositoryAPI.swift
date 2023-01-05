// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol PrefillInfoRepositoryAPI {

    func getPrefillInfo(
        dateOfBirth: Date
    ) -> AnyPublisher<PrefillInfo, NabuError>
}
