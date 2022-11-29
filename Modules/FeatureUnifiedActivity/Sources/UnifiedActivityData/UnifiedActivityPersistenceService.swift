// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import CombineExtensions
import DelegatedSelfCustodyDomain
import NetworkKit
import ToolKit
import UnifiedActivityDomain

final class UnifiedActivityPersistenceService: UnifiedActivityPersistenceServiceAPI {

    private let app: AppProtocol
    private let appDatabase: AppDatabaseAPI
    private var setupCancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = []
    private let service: UnifiedActivityServiceAPI
    private let subject: PassthroughSubject<[ActivityEntry], Never> = .init()

    init(
        appDatabase: AppDatabaseAPI,
        service: UnifiedActivityServiceAPI,
        app: AppProtocol
    ) {
        self.app = app
        self.appDatabase = appDatabase
        self.service = service
        setupPersistence()
    }

    private func setupPersistence() {
        setupCancellable = subject
            .map { entries -> [ActivityEntity] in
                entries.compactMap { entry -> ActivityEntity? in
                    guard let data = try? JSONEncoder().encode(entry) else {
                        return nil
                    }
                    guard let json = String(data: data, encoding: .utf8) else {
                        return nil
                    }
                    return ActivityEntity(identifier: entry.id, json: json, networkIdentifier: entry.network)
                }
            }
            .sink { [appDatabase] activities in
                try? appDatabase.saveActivityEntities(activities)
            }
    }

    func connect() {
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
            .map(\.data)
            .map { data in
                data.activity.map { item in
                    ActivityEntry(network: data.network, pubKey: data.pubKey, item: item)
                }
            }
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
