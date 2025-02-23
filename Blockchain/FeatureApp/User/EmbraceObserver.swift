// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import Embrace

class EmbraceObserver: Client.Observer {

    unowned let app: AppProtocol
    unowned let embrace: Embrace

    init(app: AppProtocol, embrace: Embrace = .sharedInstance()) {
        self.app = app
        self.embrace = embrace
    }

    var bag: Set<AnyCancellable> = []

    func start() {
        #if DEBUG
        return
        #else

        app.publisher(for: blockchain.user.id, as: String.self)
            .receive(on: DispatchQueue.main)
            .map(\.value)
            .sink { [embrace] identifier in
                if let identifier {
                    embrace.setUserIdentifier(identifier)
                } else {
                    embrace.clearUserIdentifier()
                }
            }
            .store(in: &bag)

        app.on(blockchain.ux.type.analytics.state)
            .receive(on: DispatchQueue.main)
            .sink { [embrace] event in
                embrace.logBreadcrumb(withMessage: event.reference.sanitised().string)
            }
            .store(in: &bag)

        app.on(blockchain.ux.type.analytics.event)
            .receive(on: DispatchQueue.main)
            .sink { [embrace] event in
                guard event.tag.isNot(blockchain.ux.type.analytics.state) else { return }
                embrace.logMessage(
                    event.reference.sanitised().string,
                    with: .info,
                    properties: event.context.sanitised().dictionary.mapKeysAndValues(
                        key: { key in key.string.prefix(128).string },
                        value: { value in value.description.prefix(256).string }
                    )
                )
            }
            .store(in: &bag)

        app.on(blockchain.ux.type.analytics.error)
            .receive(on: DispatchQueue.main)
            .sink { [embrace] event in
                struct E: Error { let message: String }
                embrace.logHandledError(
                    E(message: event.context[blockchain.ux.type.analytics.error.message].description),
                    screenshot: false,
                    properties: [
                        "file": event.context[blockchain.ux.type.analytics.error.source.file].description.prefix(256).string,
                        "line": event.context[blockchain.ux.type.analytics.error.source.line].description.prefix(256).string
                    ]
                )
            }
            .store(in: &bag)
        #endif
    }

    func stop() { bag.removeAll() }
}
