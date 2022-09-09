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

class TxNoteUpdatingTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
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
