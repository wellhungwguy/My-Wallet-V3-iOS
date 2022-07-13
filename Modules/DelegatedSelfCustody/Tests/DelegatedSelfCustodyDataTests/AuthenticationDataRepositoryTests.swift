// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import DelegatedSelfCustodyData
import DelegatedSelfCustodyDomain
import TestKit
import XCTest

final class AuthenticationDataRepositoryTests: XCTestCase {

    enum TestData {
        static let guid = "936da01f-9abd-4d9d-80c7-02af85c822a8"
        static let sharedKey = "sharedKey"
        static let guidHash = "66b4d84b49acf377cebe847c3807b62a96fd4b346c041d22baf73565fa324904"
        static let sharedKeyHash = "14428308281d2bbb5453029997691a2bc2c296dbecff2d66f890df359ac27279"
    }

    var cancellables: Set<AnyCancellable>!
    var subject: AuthenticationDataRepository!

    override func setUp() {
        let guid = GuidServiceMock()
        guid.result = .success(TestData.guid)
        let sharedKey = SharedKeyServiceMock()
        sharedKey.result = .success(TestData.sharedKey)
        subject = AuthenticationDataRepository(guidService: guid, sharedKeyService: sharedKey)
        cancellables = []
    }

    func testInitialAuthenticationData() {
        let expectation = expectation(description: "test initial authentication data")

        var error: Error?
        var receivedValue: (guid: String, sharedKeyHash: String)?
        subject.initialAuthenticationData
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
        XCTAssertEqual(receivedValue?.guid, TestData.guid)
        XCTAssertEqual(receivedValue?.sharedKeyHash, TestData.sharedKeyHash)
    }

    func testAuthenticationData() {
        let expectation = expectation(description: "test authentication data")

        var error: Error?
        var receivedValue: (guidHash: String, sharedKeyHash: String)?
        subject.authenticationData
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
        XCTAssertEqual(receivedValue?.guidHash, TestData.guidHash)
        XCTAssertEqual(receivedValue?.sharedKeyHash, TestData.sharedKeyHash)
    }
}
