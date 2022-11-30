// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExtensions

public protocol UnifiedActivityRepositoryAPI {
    var connect: AnyPublisher<Void, Never> { get }
    var activity: AnyPublisher<[ActivityEntry], Never> { get }
}

extension UnifiedActivityRepositoryAPI {
    public var connect: AnyPublisher<Void, Never> {
        activity
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
