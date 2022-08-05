// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension AppProtocol {
    public func fetchAppMode() -> AnyPublisher<AppMode, Never> {
        let superAppEnabledFlagPublisher = publisher(for: blockchain.app.configuration.app.superapp.is.enabled, as: Bool.self)
            .replaceError(with: false)

        let appModePublisher =
        publisher(for: blockchain.app.mode, as: AppMode.self)
            .map(\.value)
            .replaceNil(with: .trading)
            .replaceEmpty(with: .trading)
            .combineLatest(superAppEnabledFlagPublisher)
            .map { appMode, isEnabled -> AppMode in
                guard isEnabled else {
                    return .both
                }
                return appMode
            }
            .eraseToAnyPublisher()

        return appModePublisher
    }

    public var currentMode: AppMode {
        let featureFlagIsOn = (try? remoteConfiguration.get(blockchain.app.configuration.app.superapp.is.enabled)) ?? false

        if featureFlagIsOn {
            return (try? state.get(blockchain.app.mode, as: AppMode.self)) ?? .trading
        }
        return .both
    }
}
