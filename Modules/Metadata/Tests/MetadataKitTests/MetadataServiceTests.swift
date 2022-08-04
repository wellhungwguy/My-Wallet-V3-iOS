// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import MetadataDataKit
@testable import MetadataKit
import NetworkKit
import TestKit
import ToolKit
import XCTest

// swiftlint:disable line_length
final class MetadataServiceTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    private var subject: MetadataServiceAPI!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
    }

    override func tearDownWithError() throws {
        subject = nil
        cancellables = nil

        try super.tearDownWithError()
    }

    func test_initialize() throws {

        let environment = TestEnvironment()

        let initializedExpecation = expectation(
            description: "Metadata was successfully initialized"
        )

        let fetchCalledWithCorrectAddressExpectation = expectation(
            description: "Fetch was called with the correct address"
        )

        let expectedAddress = "12TMDMri1VSjbBw8WJvHmFpvpxzTJe7EhU"

        let fetch: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .just(MetadataPayload.rootMetadataPayload)
        }

        let put: PutMetadataEntry = { _, _ in
            XCTFail("Put should not be called")
            return .just(())
        }

        let expectedState = environment.metadataState

        subject = MetadataService(
            initialize: provideInitialize(
                fetch: fetch,
                put: put
            ),
            initializeAndRecoverCredentials: provideInitializeAndRecoverCredentials(
                fetch: fetch
            ),
            fetchEntry: provideFetchEntry(fetch: fetch),
            saveEntry: provideSave(fetch: fetch, put: put)
        )

        subject
            .initialize(
                credentials: environment.credentials,
                masterKey: environment.masterKey,
                payloadIsDoubleEncrypted: false
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [initializedExpecation] metadataState in
                XCTAssertEqual(metadataState, expectedState)
                initializedExpecation.fulfill()
            })
            .store(in: &cancellables)

        wait(
            for: [
                initializedExpecation,
                fetchCalledWithCorrectAddressExpectation
            ],
            timeout: 10.0
        )
    }

    func test_initialize_with_wrong_root_private_key_fixes_the_error() {

        let environment = TestEnvironment()

        let initializedExpecation = expectation(
            description: "Metadata was successfully initialized"
        )

        let fetchCalledWithCorrectAddressExpectation = expectation(
            description: "Fetch was called with the correct address"
        )
        // this is because before we `PUT` an entry we re fetch the entry
        fetchCalledWithCorrectAddressExpectation.expectedFulfillmentCount = 2

        let expectedAddress = "12TMDMri1VSjbBw8WJvHmFpvpxzTJe7EhU"
        // given a wrong metadata payload
        let fetch: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .just(MetadataPayload.erroreousRootMetadataPayload)
        }

        let putCalledWithCorrectAddressExpectation = expectation(
            description: "Put was called with the correct address"
        )

        let expectedRootXpriv = "xprv9uvPCc4bEjZEaAAxnva4d9gnUGPssAVsT8DfnGuLVdtD9TeQfFtfySYD7P1cBAUZSNXnT52zxxmpx4rs2pzCJxu64gpwzUdu33HEzzjbHty"
        let put: PutMetadataEntry = { address, body in
            XCTAssertEqual(address, expectedAddress)
            putCalledWithCorrectAddressExpectation.fulfill()
            let decryptedJSON = decryptMetadata(
                metadata: environment.secondPasswordNode.metadataNode,
                payload: body.payload
            ).successData ?? ""

            let decoded = decryptedJSON
                .decodeJSON(
                    to: RemoteMetadataNodesResponse.self
                )
                .successData!
            XCTAssertEqual(decoded.metadata!, expectedRootXpriv)
            return .just(())
        }

        let expectedState = environment.metadataState

        subject = MetadataService(
            initialize: provideInitialize(
                fetch: fetch,
                put: put
            ),
            initializeAndRecoverCredentials: provideInitializeAndRecoverCredentials(
                fetch: fetch
            ),
            fetchEntry: provideFetchEntry(fetch: fetch),
            saveEntry: provideSave(fetch: fetch, put: put)
        )

        subject
            .initialize(
                credentials: environment.credentials,
                masterKey: environment.masterKey,
                payloadIsDoubleEncrypted: false
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [initializedExpecation] metadataState in
                XCTAssertEqual(metadataState, expectedState)
                initializedExpecation.fulfill()
            })
            .store(in: &cancellables)

        wait(
            for: [
                initializedExpecation,
                putCalledWithCorrectAddressExpectation,
                fetchCalledWithCorrectAddressExpectation
            ],
            timeout: 10.0
        )
    }

    func test_initialize_and_recover_credentials() throws {

        let environment = TestEnvironment()

        let initializedAndRecoveredSuccessfullyExpecation = expectation(
            description: "Metadata was successfully initialized and the credentials recovered"
        )

        let fetchCalledWithCorrectAddressExpectation = expectation(
            description: "Fetch was called with the correct address"
        )

        let mnemonic = environment.mnemonic.mnemonicString

        let expectedAddress = "1EfF3b4GusL5YkKji9HxqAhDBRRvEFSZiP"

        let fetch: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .just(MetadataPayload.credentialsMetadataEntryPayload)
        }

        let put: PutMetadataEntry = { _, _ in
            XCTFail("Put should not be called")
            return .just(())
        }

        let expectedMetadataState = environment.metadataState

        let expectedCredentials = environment.credentials

        let expectedRecoveryContext = RecoveryContext(
            metadataState: expectedMetadataState,
            credentials: expectedCredentials
        )

        subject = MetadataService(
            initialize: provideInitialize(
                fetch: fetch,
                put: put
            ),
            initializeAndRecoverCredentials: provideInitializeAndRecoverCredentials(
                fetch: fetch
            ),
            fetchEntry: provideFetchEntry(fetch: fetch),
            saveEntry: provideSave(fetch: fetch, put: put)
        )

        subject
            .initializeAndRecoverCredentials(from: mnemonic)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [initializedAndRecoveredSuccessfullyExpecation] recoveryContext in
                XCTAssertEqual(recoveryContext, expectedRecoveryContext)
                initializedAndRecoveredSuccessfullyExpecation.fulfill()
            })
            .store(in: &cancellables)

        wait(
            for: [
                initializedAndRecoveredSuccessfullyExpecation,
                fetchCalledWithCorrectAddressExpectation
            ],
            timeout: 10.0
        )
    }

    func test_fetch() throws {

        let successfullyFetchedExpectation = expectation(
            description: "The entry was successfully fetched"
        )

        let fetchCalledWithCorrectAddressExpectation = expectation(
            description: "Fetch was called with the correct address"
        )

        let expectedAddress = "129GLwNB2EbNRrGMuNSRh9PM83xU2Mpn81"

        let fetch: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .just(MetadataPayload.ethereumMetadataEntryPayload)
        }

        let put: PutMetadataEntry = { _, _ in
            XCTFail("Put should not be called")
            return .just(())
        }

        let environment = TestEnvironment()

        let metadataState = environment.metadataState

        let expectedEntryPayload = EthereumEntryPayload.entry

        subject = MetadataService(
            initialize: provideInitialize(
                fetch: fetch,
                put: put
            ),
            initializeAndRecoverCredentials: provideInitializeAndRecoverCredentials(
                fetch: fetch
            ),
            fetchEntry: provideFetchEntry(fetch: fetch),
            saveEntry: provideSave(fetch: fetch, put: put)
        )

        subject
            .fetchEntry(with: metadataState)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [successfullyFetchedExpectation] (entry: EthereumEntryPayload) in
                XCTAssertEqual(entry, expectedEntryPayload)
                successfullyFetchedExpectation.fulfill()
            })
            .store(in: &cancellables)

        wait(
            for: [
                fetchCalledWithCorrectAddressExpectation,
                successfullyFetchedExpectation
            ],
            timeout: 10.0
        )
    }
}
