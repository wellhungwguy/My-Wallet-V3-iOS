import Blockchain
import Embrace

class EmbraceObserver: Session.Observer {

    unowned let app: AppProtocol
    unowned let embrace: Embrace

    init(app: AppProtocol, embrace: Embrace = .sharedInstance()) {
        self.app = app
        self.embrace = embrace
    }

    var bag: Set<AnyCancellable> = []

    func start() {

        app.on(blockchain.session.event.did.sign.in) { [embrace, app] _ async throws in
            try await embrace.setUserIdentifier(app.get(blockchain.user.id))
        }
        .store(in: &bag)

        app.on(blockchain.session.event.did.sign.out) { [embrace] _ in
            embrace.clearUserIdentifier()
        }
        .store(in: &bag)

        app.on(blockchain.ux.type.analytics.state) { [embrace] event in
            embrace.logBreadcrumb(withMessage: event.reference.string)
        }
        .store(in: &bag)

        app.on(blockchain.ux.type.analytics.event) { [embrace] event in
            embrace.logMessage(
                event.reference.string,
                with: .info,
                properties: event.context.mapKeysAndValues(key: \.description, value: \.description)
            )
        }
        .store(in: &bag)

        app.on(blockchain.ux.type.analytics.error) { [embrace] event in
            struct E: Error { let message: String }
            embrace.logHandledError(
                E(message: event.context[blockchain.ux.type.analytics.error.message].description),
                screenshot: false,
                properties: [
                    "file": event.context[blockchain.ux.type.analytics.error.source.file].description,
                    "line": event.context[blockchain.ux.type.analytics.error.source.line].description
                ]
            )
        }
        .store(in: &bag)
    }

    func stop() { bag.removeAll() }
}
