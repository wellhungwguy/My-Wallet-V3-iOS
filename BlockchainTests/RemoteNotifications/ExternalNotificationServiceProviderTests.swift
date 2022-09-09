// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainApp
import Combine
@testable import RemoteNotificationsKit
import UserNotifications
import XCTest

final class ExternalNotificationServiceProviderTests: XCTestCase {

    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = []
        try super.tearDownWithError()
    }

    func testSuccessfullTokenFetching() {
        let expectedToken = "fcm-token-value"
        let messagingService = MockMessagingService(expectedTokenResult: .success(expectedToken))
        let provider = ExternalNotificationServiceProvider(messagingService: messagingService)

        let registerExpectation = expectation(
            description: "Service registered token."
        )
        provider.token
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail("Expected successful token fetch. Got \(error) instead")
                    case .finished:
                        break
                    }
                },
                receiveValue: { token in
                    registerExpectation.fulfill()
                    XCTAssertEqual(token, expectedToken)
                }
            )
            .store(in: &cancellables)

        wait(
            for: [
                registerExpectation
            ],
            timeout: 10.0
        )
    }

    func testEmptyTokenFetchingFailure() {
        let messagingService = MockMessagingService(expectedTokenResult: .failure(.tokenIsEmpty))
        let provider = ExternalNotificationServiceProvider(messagingService: messagingService)

        let registerExpectation = expectation(
            description: "Service registered token."
        )
        provider.token
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .tokenIsEmpty:
                            registerExpectation.fulfill()
                        default:
                            XCTFail("Expected '.tokenIsEmpty' error. Got \(error) instead")
                        }
                    case .finished:
                        break
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected '.tokenIsEmpty' error. Got success instead")
                }
            )
            .store(in: &cancellables)

        wait(
            for: [
                registerExpectation
            ],
            timeout: 10.0
        )
    }

    func testTopicSubscriptionSuccess() {
        let messagingService = MockMessagingService(
            expectedTokenResult: .success(""),
            shouldSubscribeToTopicsSuccessfully: true
        )
        let provider = ExternalNotificationServiceProvider(messagingService: messagingService)
        let topic = RemoteNotification.Topic.remoteConfig
        let registerExpectation = expectation(
            description: "Service registered token."
        )
        provider.subscribe(to: topic)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        XCTFail("Expected successful topic subscription. Got \(error) instead")
                    case .finished:
                        XCTAssertTrue(messagingService.topics.contains(topic.rawValue))
                    }
                },
                receiveValue: { _ in
                    registerExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(
            for: [
                registerExpectation
            ],
            timeout: 10.0
        )
    }

    func testTopicSubscriptionFailure() {
        let messagingService = MockMessagingService(
            expectedTokenResult: .failure(.tokenIsEmpty),
            shouldSubscribeToTopicsSuccessfully: false
        )
        let provider = ExternalNotificationServiceProvider(messagingService: messagingService)
        let topic = RemoteNotification.Topic.remoteConfig

        let registerExpectation = expectation(
            description: "Service registered token."
        )
        provider.subscribe(to: topic)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .system(MockMessagingService.FakeError.subscriptionFailure):
                            XCTAssertFalse(messagingService.topics.contains(topic.rawValue))
                            registerExpectation.fulfill()
                        default:
                            XCTFail("Expected 'subscriptionFailure' error. Got \(error) instead")
                        }
                    case .finished:
                        break
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected 'subscriptionFailure' error. Got success instead")
                }
            )
            .store(in: &cancellables)

        wait(
            for: [
                registerExpectation
            ],
            timeout: 10.0
        )
    }
}
