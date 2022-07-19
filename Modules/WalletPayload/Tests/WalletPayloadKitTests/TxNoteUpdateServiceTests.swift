// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
@testable import MetadataKitMock
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock

import Combine
import TestKit
import ToolKit
import XCTest

class TxNoteUpdateServiceTests: XCTestCase {

    private let jsonV4 = Fixtures.loadJSONData(filename: "wallet.v4", in: .module)!

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_updating_tx_note_works_correctly() throws {
        let walletHolder = WalletHolder()
        let walletRepo = WalletRepo(initialState: .empty)
        let walletSync = WalletSyncMock()

        // Given
        let walletTxNoteUpdater = WalletTxNoteService(
            walletHolder: walletHolder,
            walletRepo: walletRepo,
            walletSync: walletSync,
            operationQueue: DispatchQueue(label: "txNoteUpdater.queue")
        )

        // When
        let walletResponse = try JSONDecoder().decode(WalletResponse.self, from: jsonV4)
        let nativeWallet = NativeWallet.from(blockchainWallet: walletResponse)
        let wrapper = Wrapper(
            pbkdf2Iterations: 0,
            version: 0,
            payloadChecksum: "",
            language: "",
            syncPubKeys: false,
            wallet: nativeWallet
        )
        walletHolder.hold(walletState: .loaded(wrapper: wrapper, metadata: MetadataState.mock))
            .subscribe()
            .store(in: &cancellables)
        walletRepo.set(keyPath: \.credentials.password, value: "password")

        walletSync.syncResult = .success(.noValue)

        let expectation = expectation(description: "mnemonic verification syncing")

        let expectedTxNotes = ["tx-hash": "value"]

        walletTxNoteUpdater.updateNote(txHash: "tx-hash", value: "value")
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { _ in
                    XCTAssertTrue(walletSync.syncCalled)
                    // verify that the passed `Wrapper` has been updated
                    XCTAssertNotEqual(walletSync.givenWrapper, wrapper)
                    XCTAssertEqual(walletSync.givenWrapper!.wallet.txNotes, expectedTxNotes)
                    XCTAssertEqual(walletSync.givenPassword, "password")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func test_updater_method_works_correctly() {
        typealias TestCase = () -> Void
        let testCase_EmptyCurrentNotes: TestCase = {
            let currentNotes: [String: String] = [:]
            let updatedNotes = transcationNotesUpdate(notes: currentNotes, hash: "a-hash", note: "a-value")
            let expectedNotes = ["a-hash": "a-value"]
            XCTAssertEqual(updatedNotes, expectedNotes)
        }

        let testCase_NilCurrentNotes: TestCase = {
            let currentNotes: [String: String]? = nil
            let updatedNotes = transcationNotesUpdate(notes: currentNotes, hash: "a-hash", note: "a-value")
            let expectedNotes = ["a-hash": "a-value"]
            XCTAssertEqual(updatedNotes, expectedNotes)
        }

        let testCase_Deletion: TestCase = {
            let currentNotes: [String: String]? = ["a-hash": "a-value", "b-hash": "b-value"]
            let updatedNotes = transcationNotesUpdate(notes: currentNotes, hash: "a-hash", note: nil)
            let expectedNotes: [String: String] = ["b-hash": "b-value"]
            XCTAssertEqual(updatedNotes, expectedNotes)
        }

        let testCase_Insertion: TestCase = {
            let currentNotes: [String: String]? = ["a-hash": "a-value"]
            let updatedNotes = transcationNotesUpdate(notes: currentNotes, hash: "b-hash", note: "b-value")
            let expectedNotes = ["a-hash": "a-value", "b-hash": "b-value"]
            XCTAssertEqual(updatedNotes, expectedNotes)
        }

        let testCase_Update: TestCase = {
            let currentNotes: [String: String]? = ["a-hash": "a-value"]
            let updatedNotes = transcationNotesUpdate(notes: currentNotes, hash: "b-hash", note: "b-new-value")
            let expectedNotes = ["a-hash": "a-value", "b-hash": "b-new-value"]
            XCTAssertEqual(updatedNotes, expectedNotes)
        }

        let testCases: [TestCase] = [
            testCase_EmptyCurrentNotes,
            testCase_NilCurrentNotes,
            testCase_Deletion,
            testCase_Insertion,
            testCase_Update
        ]
        for testCase in testCases {
            testCase()
        }
    }
}
