// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
@testable import DelegatedSelfCustodyData
import DelegatedSelfCustodyDomain
import TestKit
import XCTest

final class SubscriptionsStateServiceTests: XCTestCase {

    enum TestData {
        static let account = DelegatedCustodyAccount(
            coin: .bitcoin,
            derivationPath: "",
            style: "",
            publicKey: Data(),
            privateKey: Data()
        )
        static let event = blockchain.app.configuration.pubkey.service.auth
    }

    var cancellables: Set<AnyCancellable>!
    var subject: SubscriptionsStateServiceAPI!
    var accountRepository: AccountRepositoryMock!
    var app: AppProtocol!

    override func setUp() {
        super.setUp()
        accountRepository = AccountRepositoryMock()
        accountRepository.result = .success([])
        app = App.test
        subject = SubscriptionsStateService(
            accountRepository: accountRepository,
            app: app
        )
        cancellables = []
    }

    override func tearDown() {
        app.state.set(TestData.event, to: nil)
        super.tearDown()
    }

    func testEmptyStateNull() {
        app.state.set(TestData.event, to: nil)
        accountRepository.result = .success([TestData.account])
        run(name: "test empty state null", expectedValue: false)
    }

    func testEmptyStateEmptyArray() {
        app.state.set(TestData.event, to: [])
        accountRepository.result = .success([TestData.account])
        run(name: "test empty state empty array", expectedValue: false)
    }

    func testEmptyStateGarbageData() {
        app.state.set(TestData.event, to: "deadbeef")
        accountRepository.result = .success([TestData.account])
        run(name: "test empty state garbage data", expectedValue: false)
    }

    func testValidStateCompleteMatch() {
        app.state.set(TestData.event, to: [TestData.account.coin.code])
        accountRepository.result = .success([TestData.account])
        run(name: "test valid state complete match", expectedValue: true)
    }

    func testValidStatePartialMatch() {
        app.state.set(TestData.event, to: [TestData.account.coin.code, "OTHER"])
        accountRepository.result = .success([TestData.account])
        run(name: "test valid state partial match", expectedValue: true)
    }

    func testValidStateNoActive() {
        app.state.set(TestData.event, to: [TestData.account.coin.code])
        accountRepository.result = .success([])
        run(name: "test valid state no active", expectedValue: true)
    }

    func testInvalidStateNoMatch() {
        app.state.set(TestData.event, to: ["OTHER"])
        accountRepository.result = .success([TestData.account])
        run(name: "test invalid state no match", expectedValue: false)
    }

    func run(name: String, expectedValue: Bool) {
        let expectation = expectation(description: name)
        var error: Error?
        var receivedValue: Bool?
        subject.isValid
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failureError):
                        error = failureError
                    }
                },
                receiveValue: { value in
                    receivedValue = value
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        waitForExpectations(timeout: 5)
        XCTAssertNil(error)
        XCTAssertNotNil(receivedValue)
        XCTAssertEqual(receivedValue, expectedValue)
    }
}
