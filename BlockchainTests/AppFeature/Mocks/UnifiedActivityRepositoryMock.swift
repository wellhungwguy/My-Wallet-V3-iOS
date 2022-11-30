// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import UnifiedActivityDomain

final class UnifiedActivityRepositoryMock: UnifiedActivityRepositoryAPI {
    var activity: AnyPublisher<[ActivityEntry], Never> { .empty() }
}
