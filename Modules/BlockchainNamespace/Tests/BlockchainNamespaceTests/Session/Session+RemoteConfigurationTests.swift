@testable import BlockchainNamespace
import Combine
import FirebaseProtocol
import XCTest

@available(iOS 15.0, macOS 12.0, *) // Replace with `async()` API when merged
final class SessionRemoteConfigurationTests: XCTestCase {

    var preferences: Mock.UserDefaults!
    var app: AppProtocol!

    override func setUp() {
        super.setUp()
        preferences = Mock.UserDefaults()
        preferences.set(
            [
                blockchain.app.configuration.manual.login.is.enabled(\.id): false
            ],
            forKey: blockchain.session.configuration(\.id)
        )
        app = App(
            remoteConfiguration: Session.RemoteConfiguration(
                remote: Mock.RemoteConfiguration(
                    [
                        .remote: [
                            "ios_ff_apple_pay": true,
                            "blockchain_app_configuration_announcements": ["1", "2", "3"],
                            "blockchain_app_configuration_deep_link_rules": []
                        ]
                    ]
                ),
                preferences: preferences
            )
        )
    }

    func test_fetch() async throws {

        let announcements = try await app.publisher(for: blockchain.app.configuration.announcements, as: [String].self)
            .wait()

        XCTAssertEqual(announcements, ["1", "2", "3"])

        try XCTAssertEqual(app.remoteConfiguration.get(blockchain.app.configuration.announcements), ["1", "2", "3"])
    }

    func test_fetch_with_underscore() async throws {
        let deepLinkRules = try await app.publisher(for: blockchain.app.configuration.deep_link.rules, as: [App.DeepLink.Rule].self)
            .wait()

        XCTAssertEqual(deepLinkRules, [])
    }

    func test_fetch_fallback() async throws {

        let isEnabled = try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .wait()

        XCTAssertTrue(isEnabled)
    }

    func test_fetch_type_mismatch() async throws {

        let announcements = try await app.publisher(for: blockchain.app.configuration.announcements, as: Bool.self)
            .values
            .next()
            .unwrap()

        XCTAssertThrowsError(try announcements.get())
    }

    func test_fetch_missing_value() async throws {

        let announcements = try await app.publisher(for: blockchain.user.email.address, as: String.self)
            .values
            .next()
            .unwrap()

        XCTAssertThrowsError(try announcements.get())
    }

    func test_fetch_then_override() async throws {

        var announcements = try await app.publisher(for: blockchain.app.configuration.announcements, as: [String].self)
            .wait()

        XCTAssertEqual(announcements, ["1", "2", "3"])

        app.remoteConfiguration.override(blockchain.app.configuration.announcements, with: ["4", "5", "6"])

        announcements = try await app.publisher(for: blockchain.app.configuration.announcements, as: [String].self)
            .wait()

        XCTAssertEqual(announcements, ["4", "5", "6"])
    }

    func test_all_keys() async throws {

        _ = try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .wait()

        XCTAssertEqual(
            app.remoteConfiguration.allKeys.set,
            [
                "ios_ff_apple_pay",
                "!blockchain.app.configuration.manual.login.is.enabled",
                "blockchain_app_configuration_announcements",
                "blockchain_app_configuration_deep_link_rules"
            ].set
        )
    }

    func test_with_default() async throws {

        let app = App(
            remoteConfiguration: .init(
                remote: Mock.RemoteConfiguration(),
                preferences: Mock.Preferences(),
                default: [
                    blockchain.app.configuration.apple.pay.is.enabled: true
                ]
            )
        )

        var isEnabled = try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .wait()

        XCTAssertTrue(isEnabled)

        XCTAssertEqual(
            app.remoteConfiguration.allKeys.set,
            ["blockchain.app.configuration.apple.pay.is.enabled"].set
        )

        app.remoteConfiguration.override(blockchain.app.configuration.apple.pay.is.enabled, with: false)

        isEnabled = try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .wait()

        XCTAssertEqual(
            app.remoteConfiguration.allKeys.set,
            [
                "blockchain.app.configuration.apple.pay.is.enabled",
                "!blockchain.app.configuration.apple.pay.is.enabled"
            ].set
        )

        XCTAssertFalse(isEnabled)

        app.remoteConfiguration.clear(blockchain.app.configuration.apple.pay.is.enabled)

        isEnabled = try await app.publisher(for: blockchain.app.configuration.apple.pay.is.enabled, as: Bool.self)
            .wait()

        XCTAssertTrue(isEnabled)
    }

    func test_with_preferences() async throws {

        do {
            let isEnabled = try await app.publisher(
                for: blockchain.app.configuration.manual.login.is.enabled,
                as: Bool.self
            )
            .wait()

            XCTAssertFalse(isEnabled)
        }

        app.remoteConfiguration.override(blockchain.app.configuration.manual.login.is.enabled, with: true)

        do {
            let isEnabled = try await app.publisher(
                for: blockchain.app.configuration.manual.login.is.enabled,
                as: Bool.self
            )
            .wait()

            XCTAssertTrue(isEnabled)

            let preference = preferences.dictionary(
                forKey: blockchain.session.configuration(\.id)
            )?[blockchain.app.configuration.manual.login.is.enabled(\.id)]

            XCTAssertTrue(preference as? Bool == true)
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension Publisher where Output == FetchResult {

    func wait() async throws -> Any {
        try await values
            .next()
            .unwrap()
            .get()
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension Publisher where Output: FetchResult.Decoded {

    func wait() async throws -> Output.Value {
        try await values
            .next()
            .unwrap()
            .get()
    }
}
