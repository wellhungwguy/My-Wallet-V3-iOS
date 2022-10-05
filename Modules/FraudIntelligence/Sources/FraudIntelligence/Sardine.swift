//
//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.
//

import BlockchainNamespace
import Combine

public final class Sardine<MobileIntelligence: MobileIntelligence_p>: Session.Observer {

    unowned let app: AppProtocol
    var bag: Set<AnyCancellable> = []

    public init(
        _ app: AppProtocol,
        sdk _: MobileIntelligence.Type = MobileIntelligence.self
    ) {
        self.app = app
    }

    // MARK: Observers

    public func start() {

        app.on(blockchain.app.did.finish.launching)
            .combineLatest(client)
            .prefix(1)
            .sink { [weak self] event, client in
                self?.initialise(event: event, clientId: client)
            }
            .store(in: &bag)

        user.combineLatest(session, flow)
            .sink { [weak self] user, session, flow in
                self?.update(userId: user, sessionKey: session, flow: flow)
            }
            .store(in: &bag)

        app.publisher(for: blockchain.app.fraud.sardine.flow, as: [String: String].self)
            .compactMap { [language = app.language] data in
                data.value?.compactMapKeys { try? Tag.Reference(id: $0, in: language) }
            }
            .flatMap { [app] flows in
                flows.compactMapKeys(\.self)
                    .map { tag, name in app.on(tag).replaceOutput(name) }
                    .merge()
            }
            .sink { [app] name in
                app.post(value: name, of: blockchain.app.fraud.sardine.current.flow)
            }
            .store(in: &bag)

        app.publisher(for: blockchain.app.fraud.sardine.trigger, as: [Tag.Reference?].self)
            .compactMap(\.value)
            .flatMap { [app] tags in
                tags.compacted().map { tag in app.on(tag) }.merge()
            }
            .sink { [app] _ in
                app.post(event: blockchain.app.fraud.sardine.submit)
            }
            .store(in: &bag)

        app.publisher(for: blockchain.api.nabu.gateway.generate.session.headers, as: [String: String].self)
            .compactMap(\.value)
            .sink { [app] headers in
                app.state.set(blockchain.app.fraud.sardine.session, to: headers["X-Session-ID"])
            }
            .store(in: &bag)

        event.start()
    }

    public func stop() {
        bag.removeAll()
        event.stop()
    }

    // MARK: Values

    lazy var client = app.publisher(for: blockchain.app.fraud.sardine.client.identifier, as: String.self)
        .compactMap(\.value)

    lazy var session = app.publisher(for: blockchain.app.fraud.sardine.session, as: String.self)
        .compactMap(\.value)

    lazy var user = app.publisher(for: blockchain.user.id, as: String.self)
        .compactMap(\.value)

    lazy var flow = app.publisher(for: blockchain.app.fraud.sardine.current.flow, as: String.self)
        .compactMap(\.value)

    lazy var event = app.on(blockchain.app.fraud.sardine.submit) { event in
        MobileIntelligence.submitData { response in
            #if DEBUG
            print("🐟 \(response.status == true ? "✅" : "‼️")", response.message ?? event.date.description)
            #endif
        }
    }

    // MARK: Sardine Integration

    func initialise(event: Session.Event, clientId: String) {
        var options = MobileIntelligence.Options()
        options.clientId = clientId
        #if DEBUG
        options.environment = MobileIntelligence.Options.ENV_SANDBOX
        #else
        options.environment = MobileIntelligence.Options.ENV_PRODUCTION
        #endif
        MobileIntelligence.start(options)
    }

    func update(userId: String, sessionKey: String, flow: String) {
        var options = MobileIntelligence.UpdateOptions()
        options.sessionKey = sessionKey
        options.userIdHash = userId.sha256()
        options.flow = flow
        MobileIntelligence.updateOptions(options: options, completion: nil)
    }
}

extension Sardine: CustomStringConvertible {
    public var description: String { "Sardine AI 🐟 \(bag.isEmpty ? "❌ Offline" : "✅ Online")" }
}
