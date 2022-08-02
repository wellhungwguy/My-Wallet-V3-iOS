// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension AppProtocol {
    public func fetchAppMode() -> AnyPublisher<AppMode, Never> {
        publisher(for: blockchain.app.mode, as: AppMode.self)
            .replaceError(with: AppMode.both)
    }

    public var currentMode: AppMode {
        (try? state.get(blockchain.app.mode, as: AppMode.self)) ?? .both
    }
}
