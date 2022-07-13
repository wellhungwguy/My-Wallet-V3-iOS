// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import Combine
import DelegatedSelfCustodyDomain
import ToolKit
import XCTest

final class DelegatedCustodyDerivationServiceTests: XCTestCase {

    private var subject: DelegatedCustodyDerivationServiceAPI!
    private var mnemonicAccess: MnemonicAccessMock!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        mnemonicAccess = MnemonicAccessMock()
        subject = DelegatedCustodyDerivationService(mnemonicAccess: mnemonicAccess)
        cancellables = []
        super.setUp()
    }

    func testStacksDerivation() {
        mnemonicAccess.underlyingMnemonic = .just(
            "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        )

        let expectation = expectation(description: "test stacks derivation")
        var error: Error!
        var receivedValue: (publicKey: Data, privateKey: Data)!
        subject.getKeys(path: "m/44'/5757'/0'/0/0")
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
        XCTAssertEqual(receivedValue.publicKey.hex, "03d5d038bce81b3965314dba54f636f093c7dbdd6617cded013a53474fbccb100c")
        XCTAssertEqual(receivedValue.privateKey.hex, "47382d0211f3bbb11812b5e60b696a93d7ad0a91cdeb2162f7d69d4adef48b5d")
    }
}
