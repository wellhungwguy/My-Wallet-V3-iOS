// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import KeychainKit
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import KeychainKitMock
import XCTest

class WalletPersistenceTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    private var mockKeychainAccess: KeychainAccessMock!
    private var persistenceQueue: DispatchQueue!

    let expectedState = WalletRepoState(
        credentials: WalletCredentials(
            guid: "guid",
            sharedKey: "sharedKey",
            sessionToken: "sessionToken",
            password: "password"
        ),
        properties: WalletProperties(
            syncPubKeys: false,
            language: "en",
            authenticatorType: .standard
        ),
        walletPayload: .empty
    )

    override func setUp() {
        super.setUp()
        mockKeychainAccess = KeychainAccessMock(service: "")
        persistenceQueue = DispatchQueue(label: "a-queue")
        cancellables = []
    }

    override func tearDown() {
        mockKeychainAccess = nil
        persistenceQueue = nil
        cancellables = nil
        super.tearDown()
    }

    func test_wallet_persistence_can_retrieve_state() throws {

        // given a stored state
        let expectedStateAsData = try walletRepoStateEncoder(expectedState).get()
        mockKeychainAccess.readResult = .success(expectedStateAsData)

        // when retrieving an initial state
        let retrievedState: WalletRepoState? = retrieveWalletRepoState(
            keychainAccess: mockKeychainAccess
        )
        // expected decoded state should not include the password
        let retrievedExpectedState = WalletRepoState(
            credentials: WalletCredentials(
                guid: "guid",
                sharedKey: "sharedKey",
                sessionToken: "sessionToken",
                password: ""
            ),
            properties: WalletProperties(
                syncPubKeys: false,
                language: "en",
                authenticatorType: .standard
            ),
            walletPayload: .empty
        )

        // then
        XCTAssertTrue(mockKeychainAccess.readCalled)

        XCTAssertEqual(retrievedState, retrievedExpectedState)
    }

    func test_wallet_persistence_state_is_nil_in_case_of_error() throws {

        // given a success read
        let successReadResult = Result<Data, KeychainAccessError>.success(Data())
        let failureReadResult = Result<Data, KeychainAccessError>.failure(.readFailure(.itemNotFound(account: "")))

        // given a failed decoder
        var mockDecoderCalled = false
        var decodeResult: Result<WalletRepoState, WalletRepoStateCodingError> = .success(.empty)

        let mockDecoder: WalletRepoStateDecoding = { _ in
            mockDecoderCalled = true
            return decodeResult
        }

        // given
        mockKeychainAccess.readResult = successReadResult
        decodeResult = .failure(
            .decodingFailed(
                DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "")
                )
            )
        )

        // when retrieving an initial state
        var retrievedState: WalletRepoState? = retrieveWalletRepoState(
            keychainAccess: mockKeychainAccess,
            decoder: mockDecoder
        )

        // then
        XCTAssertTrue(mockKeychainAccess.readCalled)
        XCTAssertTrue(mockDecoderCalled)

        XCTAssertNil(retrievedState)

        // given
        mockKeychainAccess.readResult = failureReadResult
        decodeResult = .success(.empty)

        // when retrieving an initial state
        retrievedState = retrieveWalletRepoState(
            keychainAccess: mockKeychainAccess,
            decoder: mockDecoder
        )

        // then
        XCTAssertTrue(mockKeychainAccess.readCalled)
        XCTAssertTrue(mockDecoderCalled)

        XCTAssertNil(retrievedState)
    }

    func test_wallet_persistence_can_retrieve_state_as_publisher() throws {

        // given a stored state
        let expectedStateAsData = try walletRepoStateEncoder(expectedState).get()
        mockKeychainAccess.readResult = .success(expectedStateAsData)

        let walletPersistence = WalletRepoPersistence(
            repo: WalletRepo(initialState: .empty),
            keychainAccess: mockKeychainAccess,
            queue: persistenceQueue,
            encoder: walletRepoStateEncoder,
            decoder: walletRepoStateDecoder
        )

        let expectation = expectation(description: "retrieved wallet repo state")
        // expected decoded state should not include the password
        let retrievedExpectedState = WalletRepoState(
            credentials: WalletCredentials(
                guid: "guid",
                sharedKey: "sharedKey",
                sessionToken: "sessionToken",
                password: ""
            ),
            properties: WalletProperties(
                syncPubKeys: false,
                language: "en",
                authenticatorType: .standard
            ),
            walletPayload: .empty
        )
        // when retrieving an initial state
        var receivedState: WalletRepoState?
        walletPersistence.retrieve()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { state in
                    receivedState = state
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
        // then
        XCTAssertTrue(mockKeychainAccess.readCalled)

        XCTAssertEqual(receivedState, retrievedExpectedState)
    }

    func test_wallet_persistence_can_persist_changes() throws {

        // given a success result
        mockKeychainAccess.writeResult = .success(())

        let walletRepo = WalletRepo(initialState: .empty)

        var mockEncoderCalled = false
        let mockEncoder: WalletRepoStateEncoding = { data in
            mockEncoderCalled = true
            return walletRepoStateEncoder(data)
        }

        let walletPersistence = WalletRepoPersistence(
            repo: walletRepo,
            keychainAccess: mockKeychainAccess,
            queue: persistenceQueue,
            encoder: mockEncoder,
            decoder: walletRepoStateDecoder
        )

        let expectation = expectation(description: "can persist successfully")
        expectation.expectedFulfillmentCount = 2

        walletPersistence
            .beginPersisting()
            .print()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [mockKeychainAccess] _ in
                    XCTAssertTrue(mockEncoderCalled)
                    XCTAssertTrue(mockKeychainAccess!.writeCalled)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // setting a value to the repo should trigger a write
        walletRepo.set(keyPath: \.credentials.guid, value: "a-guid")

        wait(for: [expectation], timeout: 5)
    }

    func test_wallet_persistence_can_persist_changes_skipping_duplicates() throws {

        // given a success result
        mockKeychainAccess.writeResult = .success(())

        let walletRepo = WalletRepo(initialState: .empty)

        let walletPersistence = WalletRepoPersistence(
            repo: walletRepo,
            keychainAccess: mockKeychainAccess,
            queue: persistenceQueue,
            encoder: walletRepoStateEncoder,
            decoder: walletRepoStateDecoder
        )

        let expectation = expectation(description: "can persist successfully")
        expectation.expectedFulfillmentCount = 2

        walletPersistence
            .beginPersisting()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [mockKeychainAccess] _ in
                    XCTAssertTrue(mockKeychainAccess!.writeCalled)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // setting a value to the repo should trigger a write
        walletRepo.set(keyPath: \.credentials.guid, value: "a-guid")

        // setting the same value should not trigger another write
        walletRepo.set(keyPath: \.credentials.guid, value: "a-guid")

        wait(for: [expectation], timeout: 5)
    }

    func test_wallet_persistence_retrieves_correct_error() throws {

        // given a write error
        let expectedWriteError: KeychainAccessError = .writeFailure(.writeFailed(account: "", status: -1))
        mockKeychainAccess.writeResult = .failure(expectedWriteError)

        let walletRepo = WalletRepo(initialState: .empty)

        let walletPersistence = WalletRepoPersistence(
            repo: walletRepo,
            keychainAccess: mockKeychainAccess,
            queue: persistenceQueue,
            encoder: walletRepoStateEncoder,
            decoder: walletRepoStateDecoder
        )

        let expectation = expectation(description: "should receive error")
        expectation.expectedFulfillmentCount = 1

        walletPersistence
            .beginPersisting()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else {
                        return
                    }
                    XCTAssertEqual(
                        error,
                        .keychainFailure(expectedWriteError)
                    )
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5)
    }
}
