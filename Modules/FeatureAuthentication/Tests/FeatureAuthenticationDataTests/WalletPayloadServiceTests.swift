// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationMock
import TestKit
import ToolKit
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock
import XCTest

class WalletPayloadServiceTests: XCTestCase {

    var bag: Set<AnyCancellable> = []

    override func tearDown() {
        super.tearDown()
        bag = []
    }

    /// Tests a valid response to payload fetching that requires 2FA code
    func testValid2FAResponse() throws {
        let expectedAuthType = WalletAuthenticatorType.sms // expect SMS
        let serverResponse = WalletPayloadClient.Response.fake(
            guid: "fake-guid", // expect this fake GUID value
            authenticatorType: expectedAuthType,
            payload: nil
        )
        let mockLegacySharedKeyRepo = MockLegacySharedKeyRepository()
        let mockLegacyGuidRepo = MockLegacyGuidRepository()
        let walletRepo = WalletRepo(initialState: .empty)

        let sessionTokenSetPublisher = walletRepo.set(keyPath: \.credentials.sessionToken, value: "1234-abcd-5678-efgh").get()
        let guidSetPublisher = walletRepo.set(keyPath: \.credentials.guid, value: "fake-guid").get()
        XCTAssertPublisherCompletion([sessionTokenSetPublisher, guidSetPublisher])

        let client = MockWalletPayloadClient(result: .success(serverResponse))
        let repository = WalletPayloadRepository(apiClient: client)

        let guidRepo = GuidRepository(
            legacyGuidRepository: mockLegacyGuidRepo,
            walletRepo: walletRepo
        )
        let sharedKeyRepo = SharedKeyRepository(
            legacySharedKeyRepository: mockLegacySharedKeyRepo,
            walletRepo: walletRepo
        )
        let credentialsRepository = CredentialsRepository(
            guidRepository: guidRepo,
            sharedKeyRepository: sharedKeyRepo
        )
        let service = WalletPayloadService(
            repository: repository,
            walletRepo: walletRepo,
            credentialsRepository: credentialsRepository
        )

        // TODO: @native-wallet fix test. Failing because previously it was set to use legacy wallet.

        let serviceAuthTypePublisher = service.requestUsingSessionToken()
        XCTAssertPublisherValues(serviceAuthTypePublisher, expectedAuthType, timeout: 5.0)

        let repositoryAuthTypePublisher = walletRepo.get().map(\.properties.authenticatorType)
        XCTAssertPublisherValues(repositoryAuthTypePublisher, expectedAuthType, timeout: 5.0)
    }

    func testValidPayloadResponse() throws {
        let expectedAuthType = WalletAuthenticatorType.standard // expect no 2FA
        let date = Date()
        let serverResponse = WalletPayloadClient.Response.fake(
            guid: "fake-guid", // expect this fake GUID value
            authenticatorType: expectedAuthType,
            serverTime: date.timeIntervalSinceNow,
            payload: "{\"pbkdf2_iterations\":1,\"version\":3,\"payload\":\"payload-for-wallet\"}"
        )
        let expectedPayload = WalletPayload(
            guid: "fake-guid",
            authType: expectedAuthType.rawValue,
            language: serverResponse.language,
            shouldSyncPubKeys: false,
            time: Date(timeIntervalSince1970: serverResponse.serverTime / 1000),
            payloadChecksum: serverResponse.payloadChecksum,
            payload: WalletPayloadWrapper(pbkdf2IterationCount: 1, version: 3, payload: "payload-for-wallet")
        )
        let mockLegacySharedKeyRepo = MockLegacySharedKeyRepository()
        let mockLegacyGuidRepo = MockLegacyGuidRepository()
        let walletRepo = WalletRepo(initialState: .empty)

        let sessionTokenSetPublisher = walletRepo.set(keyPath: \.credentials.sessionToken, value: "1234-abcd-5678-efgh").get()
        let guidSetPublisher = walletRepo.set(keyPath: \.credentials.guid, value: "fake-guid").get()
        XCTAssertPublisherCompletion([sessionTokenSetPublisher, guidSetPublisher])

        let client = MockWalletPayloadClient(result: .success(serverResponse))
        let repository = WalletPayloadRepository(apiClient: client)

        let guidRepo = GuidRepository(
            legacyGuidRepository: mockLegacyGuidRepo,
            walletRepo: walletRepo
        )
        let sharedKeyRepo = SharedKeyRepository(
            legacySharedKeyRepository: mockLegacySharedKeyRepo,
            walletRepo: walletRepo
        )
        let credentialsRepository = CredentialsRepository(
            guidRepository: guidRepo,
            sharedKeyRepository: sharedKeyRepo
        )
        let service = WalletPayloadService(
            repository: repository,
            walletRepo: walletRepo,
            credentialsRepository: credentialsRepository
        )

        // TODO: @native-wallet fix test. Failing because previously it was set to use legacy wallet.

        let serviceAuthTypePublisher = service.requestUsingSessionToken()
        XCTAssertPublisherValues(serviceAuthTypePublisher, expectedAuthType, timeout: 5.0)

        let repositoryAuthTypePublisher = walletRepo.get().map(\.properties.authenticatorType)
        XCTAssertPublisherValues(repositoryAuthTypePublisher, expectedAuthType, timeout: 5.0)
        walletRepo.get()
            .map(\.walletPayload)
            .sink { payload in
                XCTAssertEqual(payload, expectedPayload)
            }
            .store(in: &bag)
    }
}
