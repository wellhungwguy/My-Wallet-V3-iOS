// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol ConfirmInfoRepositoryAPI {

    func confirmInfo(
        confirmInfo: ConfirmInfo
    ) -> AnyPublisher<ConfirmInfo, NabuError>
}
