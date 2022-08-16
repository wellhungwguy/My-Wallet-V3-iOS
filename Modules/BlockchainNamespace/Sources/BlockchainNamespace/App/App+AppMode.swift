// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum AppMode: String, Decodable, Equatable {
    case defi
    case trading
    case both

    public var displayName: String {
        switch self {
        case .defi:
            return "Private Key Wallet"
        case .trading:
            return "Trading Account"
        case .both:
            return "N/A"
        }
    }
}

extension AppProtocol {

    public func modePublisher() -> AnyPublisher<AppMode, Never> {
        publisher(for: blockchain.app.configuration.app.superapp.is.enabled, as: Bool.self)
            .replaceError(with: false)
            .flatMap { [self] isEnabled -> AnyPublisher<AppMode, Never> in
                if isEnabled {
                    return publisher(for: blockchain.app.mode, as: AppMode.self)
                        .replaceError(with: .trading)
                } else {
                    return Just(.both).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    public var currentMode: AppMode {
        if remoteConfiguration.yes(if: blockchain.app.configuration.app.superapp.is.enabled) {
            return (try? state.get(blockchain.app.mode, as: AppMode.self)) ?? .trading
        } else {
            return .both
        }
    }
}
