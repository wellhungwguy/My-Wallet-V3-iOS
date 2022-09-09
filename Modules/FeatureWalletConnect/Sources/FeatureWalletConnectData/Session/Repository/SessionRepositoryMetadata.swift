// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureWalletConnectDomain
import Foundation
import MetadataKit
import WalletPayloadKit

final class SessionRepositoryMetadata: SessionRepositoryAPI {

    private let walletConnectMetadata: WalletConnectMetadataAPI
    private let walletConnectFetcher: WalletConnectFetcherAPI
    private let nativeWalletFlag: () -> AnyPublisher<Bool, Never>

    init(
        walletConnectMetadata: WalletConnectMetadataAPI = resolve(),
        walletConnectFetcher: WalletConnectFetcherAPI = resolve(),
        nativeWalletFlag: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.walletConnectMetadata = walletConnectMetadata
        self.walletConnectFetcher = walletConnectFetcher
        self.nativeWalletFlag = nativeWalletFlag
    }

    func contains(session: WalletConnectSession) -> AnyPublisher<Bool, Never> {
        loadSessions()
            .map { sessions in
                sessions
                    .contains(where: { $0.isEqual(session) })
            }
            // in some cases WC tries to reconnect when Metadata is not yet available
            // in this case we don't want to display a first connection popup
            // the session is an existing one as it's a reconnect event
            .replaceError(with: true)
            .eraseToAnyPublisher()
    }

    func store(session: WalletConnectSession) -> AnyPublisher<Void, Never> {
        retrieve()
            .map { sessions -> [WalletConnectSession] in
                var sessions = sessions
                    .filter { item in
                        !item.isEqual(session)
                    }
                sessions.append(session)
                return sessions
            }
            .flatMap { [store] sessions -> AnyPublisher<Void, Never> in
                store(sessions)
            }
            .eraseToAnyPublisher()
    }

    func remove(session: WalletConnectSession) -> AnyPublisher<Void, Never> {
        retrieve()
            .map { sessions in
                sessions.filter { item in
                    !item.isEqual(session)
                }
            }
            .flatMap { [store] sessions -> AnyPublisher<Void, Never> in
                store(sessions)
            }
            .eraseToAnyPublisher()
    }

    func removeAll() -> AnyPublisher<Void, Never> {
        store(sessions: [])
    }

    func retrieve() -> AnyPublisher<[WalletConnectSession], Never> {
        loadSessions()
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private func loadSessions() -> AnyPublisher<[WalletConnectSession], WalletConnectMetadataError> {
        nativeWalletFlag()
            .flatMap { [walletConnectMetadata, walletConnectFetcher] isEnabled
                -> AnyPublisher<[WalletConnectSession], WalletConnectMetadataError> in
                guard isEnabled else {
                    return walletConnectMetadata.v1Sessions
                }
                return walletConnectFetcher.fetchSessions()
                    .mapError { _ in WalletConnectMetadataError.unavailable }
                    .compactMap { wrapper in
                        wrapper.retrieveSessions(version: .v1)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func store(sessions: [WalletConnectSession]) -> AnyPublisher<Void, Never> {
        nativeWalletFlag()
            .flatMap { [walletConnectMetadata, walletConnectFetcher] isEnabled -> AnyPublisher<Void, Never> in
                guard isEnabled else {
                    return walletConnectMetadata
                        .update(v1Sessions: sessions)
                        .replaceError(with: ())
                        .eraseToAnyPublisher()
                }
                return walletConnectFetcher
                    .update(v1Sessions: sessions)
                    .replaceError(with: ())
                    .mapToVoid()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
