// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain
import TestKit
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock
import XCTest

@testable import FeatureAuthenticationMock

final class JWTServiceTests: XCTestCase {

    private var subject: JWTService!
    private var jwtRepository: JWTRepositoryMock!
    private var credentialsRepo: CredentialsRepository!

    override func setUp() {
        super.setUp()

        jwtRepository = JWTRepositoryMock()
        let walletRepo = WalletRepo(initialState: .empty)
        let mockGuidRepo = GuidRepository(
            legacyGuidRepository: MockLegacyGuidRepository(),
            walletRepo: walletRepo
        )
        let mockSharedKeyRepo = SharedKeyRepository(
            legacySharedKeyRepository: MockLegacySharedKeyRepository(),
            walletRepo: walletRepo
        )
        credentialsRepo = CredentialsRepository(guidRepository: mockGuidRepo, sharedKeyRepository: mockSharedKeyRepo)
        subject = JWTService(
            jwtRepository: jwtRepository,
            credentialsRepository: credentialsRepo
        )
    }

    override func tearDown() {
        jwtRepository = nil
        subject = nil
        super.tearDown()
    }

    func testSuccessfulTokenFetch() throws {

        // Arrange
        jwtRepository.expectedResult = .success("jwt-token")
        let guidSetPublisher = credentialsRepo.set(guid: "guid")
        let sharedKeySetPublisher = credentialsRepo.set(sharedKey: "shared-key")
        XCTAssertPublisherCompletion([guidSetPublisher, sharedKeySetPublisher])

        // Act
        XCTAssertPublisherValues(subject.token, "jwt-token", timeout: 5.0)
    }

    func testFailureForMissingCredentials() throws {

        // Arrange
        jwtRepository.expectedResult = .success("jwt-token")
        let sharedKeySetPublisher = credentialsRepo.set(sharedKey: "shared-key")
        XCTAssertPublisherCompletion(sharedKeySetPublisher)

        // Act
        XCTAssertPublisherError(subject.token, .failedToRetrieveCredentials(.guid), timeout: 5.0)
    }
}
