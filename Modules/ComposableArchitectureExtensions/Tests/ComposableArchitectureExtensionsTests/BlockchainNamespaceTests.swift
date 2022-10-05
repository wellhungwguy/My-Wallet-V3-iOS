@testable import BlockchainNamespace
import ComposableArchitectureExtensions
import FirebaseProtocol
import XCTest

final class BlockchainNamespaceTests: XCTestCase {

    var app: AppProtocol!

    override func setUp() {
        super.setUp()
        app = App(remote: Mock.RemoteConfiguration())
    }

    func test() {

        let store = TestStore(
            initialState: TestState(),
            reducer: testReducer,
            environment: TestEnvironment(app: app)
        )

        app.post(event: blockchain.db.type.string)
        app.post(event: blockchain.db.type.integer)

        store.send(.observation(.start))

        app.post(event: blockchain.db.type.tag)

        app.post(event: blockchain.db.type.string)
        store.receive(
            .observation(
                .event(blockchain.db.type.string[].reference, context: [
                    blockchain.ux.type.analytics.event.source.file[]: "ComposableArchitectureExtensionsTests/BlockchainNamespaceTests.swift",
                    blockchain.ux.type.analytics.event.source.line[]: 30
                ])
            )
        ) { state in
            state.event = blockchain.db.type.string[].reference
            state.context = [
                blockchain.ux.type.analytics.event.source.file[]: "ComposableArchitectureExtensionsTests/BlockchainNamespaceTests.swift",
                blockchain.ux.type.analytics.event.source.line[]: 30
            ]
        }

        app.post(event: blockchain.db.type.boolean)
        store.receive(
            .observation(
                .event(blockchain.db.type.boolean[].reference, context: [
                    blockchain.ux.type.analytics.event.source.file[]: "ComposableArchitectureExtensionsTests/BlockchainNamespaceTests.swift",
                    blockchain.ux.type.analytics.event.source.line[]: 46
                ])
            )
        ) { state in
            state.event = blockchain.db.type.boolean[].reference
            state.context = [
                blockchain.ux.type.analytics.event.source.file[]: "ComposableArchitectureExtensionsTests/BlockchainNamespaceTests.swift",
                blockchain.ux.type.analytics.event.source.line[]: 46
            ]
        }

        app.post(event: blockchain.db.type.integer, context: [blockchain.db.type.string: "context"])
        store.receive(
            .observation(
                .event(blockchain.db.type.integer[].reference, context: [
                    blockchain.db.type.string[]: "context",
                    blockchain.ux.type.analytics.event.source.file[]: "ComposableArchitectureExtensionsTests/BlockchainNamespaceTests.swift",
                    blockchain.ux.type.analytics.event.source.line[]: 62
                ])
            )
        ) { state in
            state.event = blockchain.db.type.integer[].reference
            state.context = [
                blockchain.db.type.string[]: "context",
                blockchain.ux.type.analytics.event.source.file[]: "ComposableArchitectureExtensionsTests/BlockchainNamespaceTests.swift",
                blockchain.ux.type.analytics.event.source.line[]: 62
            ]
        }

        store.send(.observation(.stop))

        app.post(event: blockchain.db.type.boolean)
    }
}

struct TestEnvironment: BlockchainNamespaceAppEnvironment {
    var app: AppProtocol
}

struct TestState: Equatable {
    var event: Tag.Reference?
    var context: Tag.Context?
}

enum TestAction: BlockchainNamespaceObservationAction, Equatable {
    case observation(BlockchainNamespaceObservation)
}

let testReducer = Reducer<TestState, TestAction, TestEnvironment> { state, action, _ in
    switch action {
    case .observation(.event(let event, context: let context)):
        state.event = event
        state.context = context
        return .none
    case .observation:
        return .none
    }
}
.on(blockchain.db.type.string)
.on(blockchain.db.type.integer)
.on(blockchain.db.type.boolean)
