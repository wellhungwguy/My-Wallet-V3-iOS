// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
@testable import MetadataDataKit
@testable import MetadataKit
import XCTest

class InitializeAndRecoverCredentialsTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = nil

        try super.tearDownWithError()
    }

    func testInitializeAndRecoverCredentials() throws {

        let environment = TestEnvironment()

        let successfullyRecoveredAndInitializedExpectation = expectation(
            description: "The metadata root was successfully initialized and the credentials recovered"
        )

        let expectedCredentials = environment.credentials

        let fetchCalledWithCorrectAddressExpectation = expectation(
            description: "The correct node was passed in"
        )

        let expectedAddress = "1EfF3b4GusL5YkKji9HxqAhDBRRvEFSZiP"

        let expectedMetadataNodeXPriv = "xprv9uvPCc4bEjZEaAAxnva4d9gnUGPssAVsT8DfnGuLVdtD9TeQfFtfySYD7P1cBAUZSNXnT52zxxmpx4rs2pzCJxu64gpwzUdu33HEzzjbHty"
        let expectedMetadataNode = try PrivateKey
            .bitcoinKeyFromXPriv(
                xpriv: expectedMetadataNodeXPriv
            )
            .get()

        let expected = RemoteMetadataNodes(
            metadataNode: expectedMetadataNode
        )

        let fetch: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .just(MetadataPayload.credentialsMetadataEntryPayload)
        }

        let initializeAndRecoverCredentials = provideInitializeAndRecoverCredentials(
            fetch: fetch
        )

        let mnemonic = environment.mnemonic

        initializeAndRecoverCredentials(mnemonic)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(
                        "Initialisation and credentials recovery should succeed. Error: \(error)"
                    )
                case .finished:
                    break
                }
            }, receiveValue: { context in
                let metadataState = context.metadataState
                let credentials = context.credentials
                let nodes = metadataState.metadataNodes
                XCTAssertEqual(nodes, expected)
                XCTAssertEqual(nodes.metadataNode.xpriv, expectedMetadataNodeXPriv)
                XCTAssertEqual(credentials, expectedCredentials)
                successfullyRecoveredAndInitializedExpectation.fulfill()
            })
            .store(in: &cancellables)

        wait(
            for: [
                fetchCalledWithCorrectAddressExpectation,
                successfullyRecoveredAndInitializedExpectation
            ],
            timeout: 10.0
        )
    }
}
