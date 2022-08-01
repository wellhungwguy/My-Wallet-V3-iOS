@testable import BlockchainNamespace
import Combine
import FirebaseProtocol
import XCTest

final class AppTests: XCTestCase {

    var app: App = .init()
    var count: [L: Int] = [:]

    var bag: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()

        app = .init()
        count = [:]

        let observations = [
            blockchain.session.event.will.sign.in,
            blockchain.session.event.did.sign.in,
            blockchain.session.event.will.sign.out,
            blockchain.session.event.did.sign.out,
            blockchain.ux.type.analytics.event
        ]

        for event in observations {
            app.on(event)
                .sink { _ in self.count[event, default: 0] += 1 }
                .store(in: &bag)
        }
    }

    func test_pub_sub() {

        app.post(event: blockchain.session.event.will.sign.in)
        app.post(event: blockchain.session.event.did.sign.in)
        app.post(event: blockchain.session.event.will.sign.out)
        app.post(event: blockchain.session.event.did.sign.out)

        XCTAssertEqual(count[blockchain.session.event.will.sign.in], 1)
        XCTAssertEqual(count[blockchain.session.event.did.sign.in], 1)
        XCTAssertEqual(count[blockchain.session.event.will.sign.out], 1)
        XCTAssertEqual(count[blockchain.session.event.did.sign.out], 1)

        XCTAssertEqual(count[blockchain.ux.type.analytics.event], 4)
    }

    func test_ref_no_id_then_update_when_session_value_arrives() throws {

        var token: String?
        let subscription = app.publisher(for: blockchain.user.token.firebase.installation, as: String.self)
            .sink { token = $0.value }
        addTeardownBlock(subscription.cancel)

        XCTAssertNil(token)

        app.state.set(blockchain.user["Oliver"].token.firebase.installation, to: "Token")

        XCTAssertNil(token)

        app.state.set(blockchain.user.id, to: "Oliver")

        XCTAssertEqual(token, "Token")
    }

    func test_action() {
        var count: Int = 0
        let subscription = app.on(blockchain.ui.type.action.then.launch.url) { _ in count += 1 }
            .subscribe()
        addTeardownBlock {
            subscription.cancel()
        }
        app.post(event: blockchain.ux.error.then.launch.url)
        XCTAssertEqual(count, 1)
    }

    func test_action_leaf() {
        XCTAssertTrue(blockchain.ux.error.then.launch.url[].is(blockchain.ui.type.action.leaf))
    }
}

extension App {

    public convenience init(
        language: Language = Language.root.language,
        state: Tag.Context = [:],
        remote: [Mock.RemoteConfigurationSource: [String: Mock.RemoteConfigurationValue]] = [:]
    ) {
        self.init(
            language: language,
            events: .init(),
            state: .init(state),
            remoteConfiguration: Session.RemoteConfiguration(remote: Mock.RemoteConfiguration(remote))
        )
    }
}
