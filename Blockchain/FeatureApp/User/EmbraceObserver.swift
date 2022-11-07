// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
    }

    func stop() { bag.removeAll() }
}
