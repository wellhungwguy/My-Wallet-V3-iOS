// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import XCTest

@testable import BlockchainApp
@testable import FeatureAppUI

class BlockchainLinksHandlerTests: XCTestCase {

    var sut: BlockchainLinksHandler!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        cancellables = []
        sut = BlockchainLinksHandler(
            validHosts: BlockchainLinks.validLinks,
            validRoutes: BlockchainLinks.validRoutes
        )
    }

    func test_canHandle_url() {
        // given, a non valid url
        let url = URL(string: "https://google.com")!

        // when
        var canHandle = sut.canHandle(url: url)

        // then
        XCTAssertFalse(canHandle)

        // given, a valid url
        let validURL = URL(string: "https://login.blockchain.com")!

        // when
        canHandle = sut.canHandle(url: validURL)

        // then
        XCTAssertTrue(canHandle)
    }

    func test_handle_incorrect_url_ignores() {
        // given, a non valid url
        let url = URL(string: "https://google.com")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(url: url)
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

    func test_handle_correct_url_without_fragment_ignores() {
        // given, a non valid url
        let url = URL(string: "https://login.blockchain.com/")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(url: url)
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

    func test_handle_correct_url_with_correct_fragment_but_non_valid_route_ignore() {
        // given, a non valid url
        let url = URL(string: "https://login.blockchain.com/#/register")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(url: url)
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

    func test_handle_correct_url_with_correct_fragment_and_valid_route() {
        // given, a non valid url
        let url = URL(string: "https://login.blockchain.com/#/login")!

        var expectedOutcome: DeeplinkOutcome?
        let expectation = expectation(description: "")
        sut.handle(url: url)
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
        let outcome = DeeplinkOutcome.handleLink(
            .init(url: url, context: .blockchainLinks(.login))
        )
        XCTAssert(expectedOutcome == outcome)
    }
}
