import BlockchainNamespace
import Combine
import Foundation

public final class CustomerSupportObserver<Intercom: Intercom_p>: Session.Observer {

    unowned let app: AppProtocol
    let notificationCenter: NotificationCenter

    let apiKey: String
    let appId: String
    let open: (URL) -> Void
    let unreadNotificationName: NSNotification.Name
    let sdk: Intercom.Type

    private var url = URL(string: "https://support.blockchain.com")!

    public init(
        app: AppProtocol,
        notificationCenter: NotificationCenter = .default,
        apiKey: String,
        appId: String,
        open: @escaping (URL) -> Void,
        unreadNotificationName: NSNotification.Name,
        intercom: Intercom.Type = Intercom.self
    ) {
        self.app = app
        self.notificationCenter = notificationCenter
        self.apiKey = apiKey
        self.appId = appId
        self.open = open
        self.unreadNotificationName = unreadNotificationName
        sdk = intercom
    }

    private var bag: Set<AnyCancellable> = []

    public func start() {

        sdk.setApiKey(apiKey, forAppId: appId)

        app.on(blockchain.session.event.did.sign.in)
            .flatMap { [app] _ -> AnyPublisher<(String, String), Never> in
                app.publisher(for: blockchain.user.id, as: String.self)
                    .compactMap(\.value)
                    .zip(app.state.publisher(for: blockchain.user.email.address).decode().compactMap(\.value))
                    .first()
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] id, email in self?.login(id: id, email: email) }
            .store(in: &bag)

        app.on(blockchain.session.event.did.sign.out)
            .sink { [weak self] _ in self?.logout() }
            .store(in: &bag)

        app.on(blockchain.ux.customer.support.show.messenger)
            .flatMap { [app] _ -> AnyPublisher<Bool, Never> in
                app.publisher(for: blockchain.app.configuration.customer.support.is.enabled, as: Bool.self)
                    .replaceError(with: false)
                    .first()
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] isEnabled in self?.present(isEnabled) }
            .store(in: &bag)

        app.publisher(for: blockchain.app.configuration.customer.support.url, as: URL.self)
            .compactMap(\.value)
            .sink { [weak self] url in self?.url = url }
            .store(in: &bag)

        notificationCenter.publisher(for: unreadNotificationName)
            .sink { [app] _ in
                app.state.set(blockchain.ux.customer.support.unread.count, to: Int(Intercom.unreadConversationCount()))
            }
            .store(in: &bag)
    }

    public func stop() {
        bag.removeAll()
    }

    private func login(id: String, email: String) {
        let attributes = Intercom.UserAttributes()
        attributes.userId = id
        attributes.email = email
        attributes.languageOverride = Locale.preferredLanguages.first
        sdk.loginUser(with: attributes) { [app] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                app.post(error: error)
            }
        }
    }

    private func logout() {
        sdk.logout()
    }

    private func present(_ isEnabled: Bool) {
        if isEnabled {
            sdk.presentMessenger()
        } else {
            open(url)
        }
    }
}
