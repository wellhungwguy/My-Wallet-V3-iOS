//
//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.
//

import Blockchain
import Combine

public final class Sardine<MobileIntelligence: MobileIntelligence_p>: Session.Observer {

    struct Flow: Decodable, Hashable {
        let name: String
        let event: Tag.Reference
        let start: Condition?
    }

    unowned let app: AppProtocol

    var http: URLSessionProtocol
    private let baseURL = URL(string: "https://\(Bundle.main.plist?.RETAIL_CORE_URL ?? "api.blockchain.info/nabu-gateway")")!

    var bag: Set<AnyCancellable> = []

    public init(
        _ app: AppProtocol,
        http: URLSessionProtocol = URLSession.shared,
        sdk _: MobileIntelligence.Type = MobileIntelligence.self
    ) {
        self.app = app
        self.http = http
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

        app.publisher(for: blockchain.app.fraud.sardine.flow, as: [Flow].self)
            .compactMap(\.value)
            .flatMap { [app] flows -> Publishers.MergeMany<AnyPublisher<Flow, Never>> in
                flows.map { flow in app.on(flow.event).replaceOutput(with: flow) }.merge()
            }
            .withLatestFrom(app.publisher(for: blockchain.app.fraud.sardine.supported.flows, as: Set<String>.self).compactMap(\.value)) { ($0, $1) }
            .sink { [app] flow, supported in
                guard supported.contains(flow.name) else { return }
                guard flow.start.or(.yes).check(in: app) else { return }
                app.post(value: flow.name, of: blockchain.app.fraud.sardine.current.flow)
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

        app.on(blockchain.session.event.did.sign.in, blockchain.session.event.did.sign.out) { [unowned self] event in
            switch event.tag {
            case blockchain.session.event.did.sign.in:
                try await request(token: app.stream(blockchain.user.token.nabu).compactMap(\.value).next())
            case blockchain.session.event.did.sign.out:
                request(token: nil)
            default:
                break
            }
        }
        .subscribe()
        .store(in: &bag)

        request(token: nil)

        event.start()
    }

    func request(token: String?) {
        var request = URLRequest(url: baseURL.appendingPathComponent("user/risk/settings"))
        let acceptLanguage = ["Accept-Language": "application/json"]
        do {
            request.allHTTPHeaderFields = try ["Authorization": "Bearer " + token.or(throw: "No Authorization Token")] + acceptLanguage
        } catch {
            request.allHTTPHeaderFields = acceptLanguage
        }

        http.dataTaskPublisher(for: request.peek("🌎", \.cURLCommand))
            .map(\.data)
            .decode(type: [String: [[String: String]]].self, decoder: JSONDecoder())
            .sink { [app] flows in
                app.state.set(blockchain.app.fraud.sardine.supported.flows, to: flows["flows"]?.map(\.["name"]))
            }
            .store(in: &bag)
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
        options.sessionKey = sessionKey.sha256()
        options.userIdHash = userId.sha256()
        options.flow = flow
        MobileIntelligence.updateOptions(options: options, completion: nil)
    }
}

extension Sardine: CustomStringConvertible {
    public var description: String { "Sardine AI 🐟 \(bag.isEmpty ? "❌ Offline" : "✅ Online")" }
}

struct Condition: Decodable, Hashable {
    let `if`: [Tag.Reference]?
    let unless: [Tag.Reference]?
}

extension Condition {

    static var yes: Condition { Condition(if: nil, unless: nil) }

    func check(in app: AppProtocol) -> Bool {
        (`if` ?? []).allSatisfy(isYes(app)) && (unless ?? []).none(isYes(app))
    }
}

private func isYes(_ app: AppProtocol) -> (_ ref: Tag.Reference) -> Bool {
    { ref in result(app, ref).isYes }
}

private func result(_ app: AppProtocol, _ ref: Tag.Reference) -> FetchResult {
    switch ref.tag {
    case blockchain.session.state.value:
        return app.state.result(for: ref)
    case blockchain.session.configuration.value:
        return app.remoteConfiguration.result(for: ref)
    default:
        return .error(.keyDoesNotExist(ref), ref.metadata(.app))
    }
}
