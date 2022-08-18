// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import KeychainKit

class KeychainWriterTests: XCTestCase {

    func test_reader_can_write_a_value_to_the_keychain() {
        // given a successful read
        let coreWriter: CoreKeychainAction = { _ in
            errSecSuccess
        }
        let coreUpdater: CoreKeychainUpdater = { _, _ in
            errSecSuccess
        }
        let coreRemover: CoreKeychainAction = { _ in
            errSecSuccess
        }
        let writer = KeychainWriter(
            queryProvider: GenericPasswordQuery(service: "some-service"),
            coreWriter: coreWriter,
            coreUpdater: coreUpdater,
            coreRemover: coreRemover
        )

        switch writer.write(value: Data(), for: "some-key") {
        case .success: break
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_writer_updates_a_value_when_we_get_a_duplicate_error() {
        // given a successful read
        let coreWriter: CoreKeychainAction = { _ in
            errSecDuplicateItem
        }
        var updaterCalled = false
        let coreUpdater: CoreKeychainUpdater = { _, _ in
            updaterCalled = true
            return errSecSuccess
        }
        let coreRemover: CoreKeychainAction = { _ in
            errSecSuccess
        }
        let writer = KeychainWriter(
            queryProvider: GenericPasswordQuery(service: "some-service"),
            coreWriter: coreWriter,
            coreUpdater: coreUpdater,
            coreRemover: coreRemover
        )

        switch writer.write(value: Data(), for: "some-key") {
        case .success:
            // verify that the coreUpdater method was called
            XCTAssertTrue(updaterCalled)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_writer_return_failure_when_an_error_occurs() {
        // given a successful read
        let coreWriter: CoreKeychainAction = { _ in
            errSecBadReq
        }
        let coreUpdater: CoreKeychainUpdater = { _, _ in
            errSecSuccess
        }
        let coreRemover: CoreKeychainAction = { _ in
            errSecSuccess
        }
        let writer = KeychainWriter(
            queryProvider: GenericPasswordQuery(service: "some-service"),
            coreWriter: coreWriter,
            coreUpdater: coreUpdater,
            coreRemover: coreRemover
        )

        switch writer.write(value: Data(), for: "some-key") {
        case .success:
            XCTFail("should not succeed")
        case .failure(let error):
            XCTAssertEqual(
                error,
                .writeFailed(account: "some-key", status: errSecBadReq)
            )
        }
    }

    func test_writer_can_remove_an_item() {
        // given a successful read
        let coreWriter: CoreKeychainAction = { _ in
            errSecSuccess
        }
        let coreUpdater: CoreKeychainUpdater = { _, _ in
            errSecSuccess
        }
        let coreRemover: CoreKeychainAction = { _ in
            errSecSuccess
        }
        let writer = KeychainWriter(
            queryProvider: GenericPasswordQuery(service: "some-service"),
            coreWriter: coreWriter,
            coreUpdater: coreUpdater,
            coreRemover: coreRemover
        )

        switch writer.remove(for: "some-key") {
        case .success: break
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_writer_should_return_error_when_removal_failed() {
        // given a successful read
        let coreWriter: CoreKeychainAction = { _ in
            errSecSuccess
        }
        let coreUpdater: CoreKeychainUpdater = { _, _ in
            errSecSuccess
        }
        let coreRemover: CoreKeychainAction = { _ in
            errSecBadReq
        }
        let writer = KeychainWriter(
            queryProvider: GenericPasswordQuery(service: "some-service"),
            coreWriter: coreWriter,
            coreUpdater: coreUpdater,
            coreRemover: coreRemover
        )

        switch writer.remove(for: "some-key") {
        case .success:
            XCTFail("should not succeed")
        case .failure(let error):
            XCTAssertEqual(
                error,
                .removalFailed(account: "some-key", status: errSecBadReq)
            )
        }
    }
}
