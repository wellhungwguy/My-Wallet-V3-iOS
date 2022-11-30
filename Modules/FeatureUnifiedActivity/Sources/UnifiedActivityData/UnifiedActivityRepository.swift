// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import NetworkKit
import ToolKit
import UnifiedActivityDomain

final class UnifiedActivityRepository: UnifiedActivityRepositoryAPI {

    private struct Key: Hashable {}

    var activity: AnyPublisher<[ActivityEntry], Never> {
        connect()
        return subject.eraseToAnyPublisher()
    }

    private let app: AppProtocol
    private var cancellables: Set<AnyCancellable> = []
    private let service: UnifiedActivityService
    private let subject: CurrentValueSubject<[ActivityEntry], Never> = .init([])

    init(service: UnifiedActivityService, app: AppProtocol) {
        self.app = app
        self.service = service
    }

    private func connect() {
        cancellables = []
        let stream = isEnabled
            .flatMap { [service] isEnabled -> AnyPublisher<WebSocketConnection.Event, Never> in
                guard isEnabled else {
                    return .empty()
                }
                return service.connect
            }
            .share()
        stream
            .compactMap { event -> WebSocketEvent? in
                switch event {
                case .received(.string(let string)):
                    return try? JSONDecoder().decode(WebSocketEvent.self, from: Data(string.utf8))
                case .received(.data):
                    return nil
                case .connected, .disconnected:
                    return nil
                }
            }
            .compactMap { event -> WebSocketEvent.Payload? in
                switch event {
                case .heartbeat:
                    return nil
                case .update(let payload), .snapshot(let payload):
                    return payload
                }
            }
            .map(\.data.activity)
            .scan([], +)
            .sink(receiveValue: { [subject] items in
                subject.send(items)
            })
            .store(in: &cancellables)

        stream
            .filter { $0 == .connected }
            .flatMap { [service] _ in
                service.subscribeToActivity
            }
            .subscribe()
            .store(in: &cancellables)
    }

    private var isEnabled: AnyPublisher<Bool, Never> {
        guard BuildFlag.isInternal else {
            return .just(false)
        }
        return app
            .publisher(for: blockchain.app.configuration.app.superapp.v1.is.enabled, as: Bool.self)
            .prefix(1)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
