// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ToolKit

public protocol WalletConnectFetcherAPI {
    func fetchSessions() -> AnyPublisher<WalletConnectSessionWrapper, WalletAssetFetchError>

    func update(v1Sessions: [WalletConnectSession]) -> AnyPublisher<Void, WalletAssetSaveError>
}

public enum WalletConnectSessionVersion: String {
    case v1
}

/// A wrapper that encapsulates the versions on WalletConnectSession from metadata
public struct WalletConnectSessionWrapper: Codable {
    enum CodingKeys: String, CodingKey {
        case sessions
    }

    let sessions: [String: [WalletConnectSession]]

    init(sessions: [String: [WalletConnectSession]]) {
        self.sessions = sessions
    }

    public func retrieveSessions(version: WalletConnectSessionVersion) -> [WalletConnectSession]? {
        sessions[version.rawValue]
    }
}

final class WalletConnectFetcher: WalletConnectFetcherAPI {

    private let metadataEntryService: WalletMetadataEntryServiceAPI

    init(metadataEntryService: WalletMetadataEntryServiceAPI) {
        self.metadataEntryService = metadataEntryService
    }

    func fetchSessions() -> AnyPublisher<WalletConnectSessionWrapper, WalletAssetFetchError> {
        metadataEntryService.fetchEntry(type: WalletConnectEntryPayload.self)
            .compactMap(\.sessions)
            .map(WalletConnectSessionWrapper.init(sessions:))
            .eraseToAnyPublisher()
    }

    func update(v1Sessions: [WalletConnectSession]) -> AnyPublisher<Void, WalletAssetSaveError> {
        let node = WalletConnectEntryPayload(
            sessions: [
                WalletConnectSessionVersion.v1.rawValue: v1Sessions
            ]
        )
        return metadataEntryService.save(node: node)
            .mapToVoid()
    }
}
