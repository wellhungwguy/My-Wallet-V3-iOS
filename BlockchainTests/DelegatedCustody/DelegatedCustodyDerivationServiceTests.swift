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

    func testDerivation1() {
        runStacksDerivation(
            mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
            publicKey: "03d5d038bce81b3965314dba54f636f093c7dbdd6617cded013a53474fbccb100c",
            privateKey: "47382d0211f3bbb11812b5e60b696a93d7ad0a91cdeb2162f7d69d4adef48b5d"
        )
    }

    func testDerivation2() {
        runStacksDerivation(
            mnemonic: "bicycle balcony prefer kid flower pole goose crouch century lady worry flavor",
            publicKey: "0218c319812eb712a135c9eebc28be7de54535c5fd0f739f8b5e9dbc8300dec3be",
            privateKey: "d31db6548076af1be636af1d633674258509326dc7ec4794b196fcb38d53569f"
        )
    }

    func testDerivation3() {
        runStacksDerivation(
            mnemonic: "radar blur cabbage chef fix engine embark joy scheme fiction master release",
            publicKey: "037c59c9451cf871c1399b07ebcdabd1b89f202582731703c4db4661253e530314",
            privateKey: "389f0c7f676249958c9977d114885ed66e42e2859d3af266ddd4d65482804729"
        )
    }

    func testDerivation4() {
        runStacksDerivation(
            mnemonic: "car region outdoor punch poverty shadow insane claim one whisper learn alert",
            publicKey: "0205fd97d83e031f58e1e627ddda1ab6fe95f9f4974d2fc7895347a94644c71b5a",
            privateKey: "538f71414ca7856ade36e80da1a4a1295886848d5c8d2635fb07da659a8d839d"
        )
    }

    private func runStacksDerivation(mnemonic: String, publicKey: String, privateKey: String) {
        mnemonicAccess.underlyingMnemonic = .just(
            mnemonic
        )

        let expectation = expectation(description: "test stacks derivation for \(mnemonic)")
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
        XCTAssertEqual(receivedValue.publicKey.hex, publicKey)
        XCTAssertEqual(receivedValue.privateKey.hex, privateKey)
    }
}
