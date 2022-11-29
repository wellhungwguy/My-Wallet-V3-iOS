import Blockchain

final class GenerateSession: Session.Observer {

    unowned var app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }

    private let id: UUID = UUID()
    private var subscription: Task<Void, Never>?

    func start() {
        subscription = Task {
            if (try? await app.get(blockchain.api.nabu.gateway.generate.session.is.enabled)) ?? true {
                app.state.set(blockchain.api.nabu.gateway.generate.session.headers, to: ["X-Session-ID": id.uuidString])
            }
        }
    }

    func stop() {
        subscription?.cancel()
    }
}
