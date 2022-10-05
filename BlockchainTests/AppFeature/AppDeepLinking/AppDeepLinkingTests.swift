// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import XCTest

@testable import BlockchainApp
@testable import FeatureAppUI

class AppDeepLinkingTests: XCTestCase {

    var sut: AppDeeplinkHandler!
    var mockDeeplinkHandler: MockURIHandler!
    var mockBlockchainHandler: MockURIHandler!
    var mockFirebaseHandler: MockURIHandler!

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        mockDeeplinkHandler = MockURIHandler()
        mockBlockchainHandler = MockURIHandler()
        mockFirebaseHandler = MockURIHandler()
        sut = AppDeeplinkHandler(
            deeplinkHandler: mockDeeplinkHandler,
            blockchainHandler: mockBlockchainHandler,
            firebaseHandler: mockFirebaseHandler
        )
    }

    func test_canHandle_url_checks_all_sub_handlers() {
        // given
        let url = URL(string: "https://blockchain.com")!

        mockDeeplinkHandler.canHandle = true
        mockBlockchainHandler.canHandle = false
        mockFirebaseHandler.canHandle = false

        // when
        var canHandle = sut.canHandle(deeplink: .url(url))

        // then
        XCTAssertTrue(canHandle)

        // given
        mockDeeplinkHandler.canHandle = false
        mockBlockchainHandler.canHandle = true
        mockFirebaseHandler.canHandle = false

        // when
        canHandle = sut.canHandle(deeplink: .url(url))

        // then
        XCTAssertTrue(canHandle)

        // given
        mockDeeplinkHandler.canHandle = false
        mockBlockchainHandler.canHandle = false
        mockFirebaseHandler.canHandle = true

        // when
        canHandle = sut.canHandle(deeplink: .url(url))

        // then
        XCTAssertTrue(canHandle)

        // given
        mockDeeplinkHandler.canHandle = false
        mockBlockchainHandler.canHandle = false
        mockFirebaseHandler.canHandle = false

        // when
        canHandle = sut.canHandle(deeplink: .url(url))

        // then
        XCTAssertFalse(canHandle)
    }

    func test_handling_urls() {
        // given
        mockDeeplinkHandler.canHandle = true
        let url = URL(string: "https://")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(deeplink: .url(url))
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { outcome in
                expectedOutcome = outcome
            }
            .store(in: &cancellables)

        // when
        let outcome = DeeplinkOutcome.handleLink(URIContent(url: url, context: .executeDeeplinkRouting))
        mockDeeplinkHandler.passthroughSubject.send(outcome)
        mockDeeplinkHandler.passthroughSubject.send(completion: .finished)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(expectedOutcome)
        XCTAssert(expectedOutcome == outcome)
    }

    func test_handling_user_activity_blockchain_handler() {
        // given
        mockBlockchainHandler.canHandle = true
        let url = URL(string: "https://login.blockchain.com")!
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = url

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")

        sut.handle(deeplink: .userActivity(userActivity))
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { outcome in
                expectedOutcome = outcome
            }
            .store(in: &cancellables)

        // when
        let outcome = DeeplinkOutcome.handleLink(URIContent(url: url, context: .blockchainLinks(.login)))
        mockBlockchainHandler.passthroughSubject.send(outcome)
        mockBlockchainHandler.passthroughSubject.send(completion: .finished)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(expectedOutcome)
        XCTAssert(expectedOutcome == outcome)
    }

    func test_handling_user_activity_firebase_handling() {
        // given
        mockBlockchainHandler.canHandle = false
        mockFirebaseHandler.canHandle = true
        let url = URL(string: "https://firebase.page.link")!
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = url

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")

        sut.handle(deeplink: .userActivity(userActivity))
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { outcome in
                expectedOutcome = outcome
            }
            .store(in: &cancellables)

        // when
        let outcome = DeeplinkOutcome.handleLink(URIContent(url: url, context: .dynamicLinks))
        mockFirebaseHandler.passthroughSubject.send(outcome)
        mockFirebaseHandler.passthroughSubject.send(completion: .finished)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(expectedOutcome)
        XCTAssert(expectedOutcome == outcome)
    }

    func test_handling_user_activity_with_no_url_returns_just_ignores() {

        mockBlockchainHandler.canHandle = true
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = nil

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")

        sut.handle(deeplink: .userActivity(userActivity))
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: { outcome in
                expectedOutcome = outcome
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertNotNil(expectedOutcome)
        XCTAssert(expectedOutcome == .ignore)
    }
}
