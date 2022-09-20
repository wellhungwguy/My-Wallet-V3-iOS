// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class MnemonicProviderTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_provides_correct_mnemonic() {
        let expectation = expectation(description: "provides a correct mnemonic")

        let expectedMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        let dispatchQueue = DispatchQueue(label: "mnemonic.provider.temp.op.queue")
        provideMnemonic(strength: .normal, queue: dispatchQueue) { bytes in
            .just(Data(repeating: 0, count: bytes))
        }
        .sink { completion in
            guard case .failure = completion else {
                return
            }
            XCTFail("should provide correct value")
        } receiveValue: { mnemonic in
            XCTAssertFalse(mnemonic.isEmpty)
            XCTAssertEqual(mnemonic, expectedMnemonic)
            expectation.fulfill()
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }
}
