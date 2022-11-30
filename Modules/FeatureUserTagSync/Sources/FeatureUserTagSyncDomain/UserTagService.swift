// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol UserTagServiceAPI {
    func updateSuperAppTag(isEnabled: Bool) -> AnyPublisher<Void, NetworkError>
}
