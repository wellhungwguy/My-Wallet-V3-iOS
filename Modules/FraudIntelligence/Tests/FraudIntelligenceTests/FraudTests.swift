import BlockchainNamespace
@testable import FraudIntelligence
import XCTest

final class FraudIntelligenceTests: XCTestCase {

    var app: AppProtocol!
    var sut: Sardine<Test.MobileIntelligence>!

    override func setUp() {
        super.setUp()
        app = App.test
        app.state.set(blockchain.ux.transaction.id, to: "buy")
        sut = Sardine(app)
        sut.start()
    }

    override func tearDown() {
        sut.stop()
        sut = nil
        app = nil
        Test.MobileIntelligence.tearDown()
        super.tearDown()
    }

    func initialise() {

        app.post(event: blockchain.app.did.finish.launching)
        app.remoteConfiguration.override(blockchain.app.fraud.sardine.client.identifier, with: "client-id")
    }

    func test_initialise() {

        XCTAssertNil(Test.MobileIntelligence.options)

        initialise()

        XCTAssertNotNil(Test.MobileIntelligence.options)
        XCTAssertEqual(Test.MobileIntelligence.options.clientId, "client-id")
    }

    func test_update() {

        initialise()

        XCTAssertNil(Test.MobileIntelligence.options.userIdHash)
        XCTAssertNil(Test.MobileIntelligence.options.sessionKey)
        XCTAssertNil(Test.MobileIntelligence.options.flow)

        app.state.set(blockchain.user.id, to: "user-id")

        XCTAssertNil(Test.MobileIntelligence.options.userIdHash)
        XCTAssertNil(Test.MobileIntelligence.options.sessionKey)
        XCTAssertNil(Test.MobileIntelligence.options.flow)

        app.state.transaction { state in
            state.set(blockchain.user.id, to: "user-id")
            state.set(blockchain.app.fraud.sardine.session, to: "session-id")
            state.set(blockchain.app.fraud.sardine.current.flow, to: "order")
        }

        XCTAssertEqual(Test.MobileIntelligence.options.userIdHash, "user-id".sha256())
        XCTAssertEqual(Test.MobileIntelligence.options.sessionKey, "session-id")
        XCTAssertEqual(Test.MobileIntelligence.options.flow, "order")
    }

    func test_flow() throws {

        do {
            initialise()
            app.state.transaction { state in
                state.set(blockchain.user.id, to: "user-id")
                state.set(blockchain.app.fraud.sardine.session, to: "session-id")
            }
        }

        let flows: Tag.Context = [
            blockchain.session.event.will.sign.in: "login",
            blockchain.ux.transaction.event.did.start: "order"
        ]

        let flow = { [state = app.state] in
            try state.get(blockchain.app.fraud.sardine.current.flow) as String
        }

        app.remoteConfiguration.override(blockchain.app.fraud.sardine.flow, with: flows.dictionary)
        XCTAssertThrowsError(try flow())
        XCTAssertNil(Test.MobileIntelligence.options.flow)

        app.post(event: blockchain.session.event.will.sign.in)
        XCTAssertEqual(try flow(), "login")
        XCTAssertEqual(Test.MobileIntelligence.options.flow, "login")

        app.post(event: blockchain.ux.transaction.event.did.start)
        XCTAssertEqual(try flow(), "order")
        XCTAssertEqual(Test.MobileIntelligence.options.flow, "order")
    }

    func test_trigger() throws {

        let triggers: [Tag.Event] = [
            blockchain.session.event.did.sign.in,
            blockchain.ux.transaction.event.did.finish
        ]

        app.remoteConfiguration.override(blockchain.app.fraud.sardine.trigger, with: triggers)

        var count = 0
        let subscription = app.on(blockchain.app.fraud.sardine.submit) { _ in count += 1 }
        subscription.start()
        defer { subscription.stop() }

        app.post(event: blockchain.session.event.will.sign.in)
        XCTAssertEqual(count, 0)
        XCTAssertEqual(Test.MobileIntelligence.count, 0)

        app.post(event: blockchain.session.event.did.sign.in)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(Test.MobileIntelligence.count, 1)

        app.post(event: blockchain.ux.transaction.event.did.finish)
        XCTAssertEqual(count, 2)
        XCTAssertEqual(Test.MobileIntelligence.count, 2)
    }
}

enum Test {

    class MobileIntelligence: MobileIntelligence_p {

        static var options: Options!
        static var count: Int = 0

        static func tearDown() {
            options = nil
            count = 0
        }

        static func start(_ options: Options) {
            Self.count = 0
            Self.options = options
        }

        static func submitData(completion: @escaping ((Response) -> Void)) {
            count += 1
            completion(Response(status: true, message: nil))
        }

        static func updateOptions(options: UpdateOptions, completion: ((Response) -> Void)?) {
            Self.options.sessionKey = options.sessionKey
            Self.options.flow = options.flow
            Self.options.userIdHash = options.userIdHash
            completion?(Response(status: true, message: nil))
        }
    }
}

extension Test.MobileIntelligence {

    struct Options: MobileIntelligenceOptions_p {

        var clientId: String?
        var sessionKey: String?
        var userIdHash: String?
        var environment: String?
        var flow: String?
        var partnerId: String?
        var enableBehaviorBiometrics: Bool?
        var enableClipboardTracking: Bool?

        static var ENV_SANDBOX: String = "ENV_SANDBOX"
        static var ENV_PRODUCTION: String = "ENV_PRODUCTION"

        static var last = (
            sessionKey: "",
            flow: ""
        )
    }

    struct UpdateOptions: MobileIntelligenceUpdateOptions_p {

        var userIdHash: String?
        var sessionKey: String
        var flow: String

        init() {
            sessionKey = Test.MobileIntelligence.Options.last.sessionKey
            flow = Test.MobileIntelligence.Options.last.sessionKey
        }
    }

    struct Response: MobileIntelligenceResponse_p {
        var status: Bool?
        var message: String?
    }
}
