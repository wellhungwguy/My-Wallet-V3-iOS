@testable import BlockchainNamespace
import Combine
import FirebaseProtocol
import XCTest

var rules: [App.DeepLink.Rule] = [
    .init(
        pattern: "/app/asset/buy(.*?)",
        event: blockchain.app.deep_link.buy[].reference,
        parameters: [
            .init(
                name: "code",
                alias: blockchain.app.deep_link.buy.crypto[]
            )
        ]
    ),
    .init(
        pattern: "/app/asset/(?<code>.*[^/?])/buy(.*?)",
        event: blockchain.app.deep_link.buy[].reference,
        parameters: [
            .init(
                name: "code",
                alias: blockchain.app.deep_link.buy.crypto[]
            )
        ]
    ),
    .init(
        pattern: "/app/asset/(?<code>.*[^/?])(.*?)",
        event: blockchain.app.deep_link.asset[].reference,
        parameters: [
            .init(
                name: "code",
                alias: blockchain.app.deep_link.asset.code[]
            )
        ]
    ),
    .init(
        pattern: "/app/qr/scan(.*?)",
        event: blockchain.app.deep_link.qr[].reference,
        parameters: []
    ),
    .init(
        pattern: "/app/kyc(.*?)",
        event: blockchain.app.deep_link.kyc[].reference,
        parameters: [
            .init(
                name: "tier",
                alias: blockchain.app.deep_link.kyc.tier[]
            )
        ]
    ),
    .init(
        pattern: "/app/asset(.*?)",
        event: blockchain.app.deep_link.asset[].reference,
        parameters: [
            .init(
                name: "code",
                alias: blockchain.app.deep_link.asset.code[]
            )
        ]
    )
]

var remoteRules: Mock.RemoteConfigurationValue {
    Mock.RemoteConfigurationValue(
        // swiftlint:disable force_try
        dataValue: try! JSONEncoder().encode(rules)
    )
}

final class AppDeepLinkTests: XCTestCase {

    var app: App = .init()
    var bag: Set<AnyCancellable> = []
    var count: [Tag: UInt] = [:]

    override func setUp() {
        super.setUp()
        app = .init(
            remote: Mock.RemoteConfiguration(
                [
                    .remote: [
                        "blockchain_app_configuration_deep_link_rules": remoteRules
                    ]
                ]
            )
        )
        app.state.set(blockchain.app.deep_link.dsl.is.enabled, to: true)
    }

    func test_handle_deep_link() throws {

        app.state.set(blockchain.app.is.ready.for.deep_link, to: true)

        app.on(blockchain.db.type.string)
            .sink { event in self.count[event.reference.tag, default: 0] += 1 }
            .store(in: &bag)

        app.post(
            event: blockchain.app.process.deep_link,
            context: [
                blockchain.app.process.deep_link.url: URL(
                    string: "https://blockchain.com/app?blockchain.db.type.string=test#blockchain.db.type.string"
                )!
            ]
        )
        XCTAssertEqual(count[blockchain.db.type.string], 1)
        try XCTAssertEqual(app.state.get(blockchain.db.type.string), "test")
    }

    func test_handle_deep_link_is_deferred_until_ready() throws {

        let event = expectation(description: #function)
        event.assertForOverFulfill = false

        app.on(blockchain.db.type.string)
            .sink { _ in event.fulfill() }
            .store(in: &bag)

        app.post(
            event: blockchain.app.process.deep_link,
            context: [
                blockchain.app.process.deep_link.url: URL(
                    string: "https://blockchain.com/app?blockchain.db.type.string=test#blockchain.db.type.string"
                )!
            ]
        )

        XCTAssertThrowsError(try app.state.get(blockchain.db.type.string))

        app.state.set(blockchain.app.is.ready.for.deep_link, to: true)

        wait(for: [event], timeout: 0.1)

        try XCTAssertEqual(app.state.get(blockchain.db.type.string), "test")
    }

    func test_deep_link_rules() throws {
        let scanUrl = URL(string: "https://blockchain.com/app/qr/scan/")!
        XCTAssertNotNil(rules.match(for: scanUrl))

        let assetUrl = URL(string: "https://blockchain.com/#/app/asset?code=BTC")!
        let assetMatch = rules.match(for: assetUrl)
        XCTAssertEqual(assetMatch?.rule.event, blockchain.app.deep_link.asset[].reference)
        XCTAssertEqual(assetMatch?.parameters().first?.value, "BTC")

        let assetUrl2 = URL(string: "https://blockchain.com/app/asset/BTC")!
        let assetMatch2 = rules.match(for: assetUrl2)
        XCTAssertEqual(assetMatch2?.rule.event, blockchain.app.deep_link.asset[].reference)
        XCTAssertEqual(assetMatch2?.parameters().first?.value, "BTC")

        let buyUrl = URL(string: "https://blockchain.com/app/asset/buy?codeCrypto=BTC")!
        let buyMatch = rules.match(for: buyUrl)
        XCTAssertEqual(buyMatch?.rule.event, blockchain.app.deep_link.buy[].reference)
        XCTAssertEqual(buyMatch?.parameters().count, 0)

        let buyUrl2 = URL(string: "https://login.blockchain.com/#/app/asset/BTC/buy/foo?tag=123")!
        let buyMatch2 = rules.match(for: buyUrl2)
        XCTAssertEqual(buyMatch2?.rule.event, blockchain.app.deep_link.buy[].reference)
        XCTAssertEqual(buyMatch2?.parameters().first?.value, "BTC")

        let kycUrl = URL(string: "https://blockchain.com/app/kyc?tier=123&tag=1234")!
        let kycMatch = rules.match(for: kycUrl)
        XCTAssertNotNil(kycMatch)
        XCTAssertEqual(kycMatch!.parameters().count, 1)
    }
}
