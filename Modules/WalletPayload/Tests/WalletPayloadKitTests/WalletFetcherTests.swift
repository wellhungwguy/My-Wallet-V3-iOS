// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
@testable import MetadataKitMock
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock

import Combine
import ObservabilityKit
import TestKit
import ToolKit
import XCTest

// swiftlint:disable line_length
class WalletFetcherTests: XCTestCase {

    let jsonV4 = Fixtures.loadJSONData(filename: "wallet-wrapper-v4", in: .module)!

    private var cancellables: Set<AnyCancellable>!
    private var walletRepo: WalletRepo!

    override func setUp() {
        super.setUp()
        walletRepo = WalletRepo(initialState: .empty)
        cancellables = []
    }

    func test_wallet_fetcher_is_able_to_fetch_using_password() throws {
        let dispatchQueue = DispatchQueue(label: "wallet.fetcher.op-queue")
        let payloadCrypto = PayloadCrypto(cryptor: AESCryptor())
        let walletHolder = WalletHolder()
        let decoder = WalletDecoder()
        let metadataService = MetadataServiceMock()
        let notificationCenterSpy = NotificationCenterSpy()
        let upgrader = WalletUpgrader(workflows: [])
        let walletSyncMock = WalletSyncMock()
        let walletPayloadRepository = WalletPayloadRepository(
            apiClient: MockWalletPayloadClient(result: .failure(.from(.unknown)))
        )
        var checkAndSaveWalletCredentialsCalled = false
        var checkAndSaveWalletCredentialsProperies: (guid: String?, sharedKey: String?, password: String?) = (nil, nil, nil)
        let checkAndSaveWalletCredentialsMock: CheckAndSaveWalletCredentials = { guid, sharedKey, password
            -> AnyPublisher<EmptyValue, Never> in
            checkAndSaveWalletCredentialsProperies = (guid, sharedKey, password)
            checkAndSaveWalletCredentialsCalled = true
            return .just(.noValue)
        }

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder.createWallet,
            upgrader: upgrader,
            metadata: metadataService,
            walletSync: walletSyncMock,
            notificationCenter: notificationCenterSpy,
            logger: NoopNativeWalletLogging(),
            payloadHealthChecker: { .just($0) },
            checkAndSaveWalletCredentials: checkAndSaveWalletCredentialsMock
        )
        let walletFetcher = WalletFetcher(
            walletRepo: walletRepo,
            payloadCrypto: payloadCrypto,
            walletLogic: walletLogic,
            walletPayloadRepository: walletPayloadRepository,
            operationsQueue: dispatchQueue,
            tracer: LogMessageTracing.noop,
            logger: NoopNativeWalletLogging()
        )

        let encryptedPayload = String(data: jsonV4, encoding: .utf8)!
        let walletPayload = WalletPayload(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            authType: 0,
            language: "en",
            shouldSyncPubKeys: false,
            time: Date(),
            payloadChecksum: "",
            payload: try? WalletPayloadWrapper(string: encryptedPayload)
        )
        walletRepo.set(
            keyPath: \.walletPayload,
            value: walletPayload
        )
        var receivedValue: WalletFetchedContext?
        let expectedValue = WalletFetchedContext(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            sharedKey: "b4a3dcbc-3e85-4cbf-8d0f-e31f9663e888",
            passwordPartHash: "561e1"
        )
        var error: Error?
        let expectation = expectation(description: "wallet-fetching-expectation")

        metadataService.initializeValue = .just(MetadataState.mock)

        walletFetcher.fetch(using: "misura12!")
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failureError):
                    error = failureError
                }
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)

        XCTAssertTrue(walletHolder.walletState.value!.isInitialised)
        XCTAssertEqual(receivedValue, expectedValue)
        XCTAssertNil(error)

        XCTAssertTrue(checkAndSaveWalletCredentialsCalled)
        XCTAssertEqual(checkAndSaveWalletCredentialsProperies.guid, expectedValue.guid)
        XCTAssertEqual(checkAndSaveWalletCredentialsProperies.sharedKey, expectedValue.sharedKey)
        XCTAssertEqual(checkAndSaveWalletCredentialsProperies.password, "misura12!")

        // Ensure we send both notification
        XCTAssertTrue(notificationCenterSpy.postNotificationCalled)
        XCTAssertEqual(
            notificationCenterSpy.postNotifications,
            [
                Notification(name: .walletInitialized),
                Notification(name: .walletMetadataLoaded)
            ]
        )
    }

    func test_wallet_fetcher_is_able_to_fetch_using_guid_sharedKey() throws {
        let dispatchQueue = DispatchQueue(label: "wallet.fetcher.op-queue")
        let payloadCrypto = PayloadCrypto(cryptor: AESCryptor())
        let walletHolder = WalletHolder()
        let decoder = WalletDecoder()
        let metadataService = MetadataServiceMock()
        let notificationCenterSpy = NotificationCenterSpy()
        let upgrader = WalletUpgrader(workflows: [])
        let walletSyncMock = WalletSyncMock()

        var checkAndSaveWalletCredentialsCalled = false
        var checkAndSaveWalletCredentialsProperies: (guid: String?, sharedKey: String?, password: String?) = (nil, nil, nil)
        let checkAndSaveWalletCredentialsMock: CheckAndSaveWalletCredentials = { guid, sharedKey, password
            -> AnyPublisher<EmptyValue, Never> in
            checkAndSaveWalletCredentialsProperies = (guid, sharedKey, password)
            checkAndSaveWalletCredentialsCalled = true
            return .just(.noValue)
        }

        let response = WalletPayloadClient.Response(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            authType: 0,
            language: "en",
            serverTime: 0,
            payload: String(data: jsonV4, encoding: .utf8)!,
            shouldSyncPubkeys: false,
            payloadChecksum: ""
        )

        let walletPayloadRepository = WalletPayloadRepository(
            apiClient: MockWalletPayloadClient(result: .success(response))
        )
        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder.createWallet,
            upgrader: upgrader,
            metadata: metadataService,
            walletSync: walletSyncMock,
            notificationCenter: notificationCenterSpy,
            logger: NoopNativeWalletLogging(),
            payloadHealthChecker: { .just($0) },
            checkAndSaveWalletCredentials: checkAndSaveWalletCredentialsMock
        )
        let walletFetcher = WalletFetcher(
            walletRepo: walletRepo,
            payloadCrypto: payloadCrypto,
            walletLogic: walletLogic,
            walletPayloadRepository: walletPayloadRepository,
            operationsQueue: dispatchQueue,
            tracer: LogMessageTracing.noop,
            logger: NoopNativeWalletLogging()
        )

        let encryptedPayload = String(data: jsonV4, encoding: .utf8)!
        let walletPayload = WalletPayload(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            authType: 0,
            language: "en",
            shouldSyncPubKeys: false,
            time: Date(),
            payloadChecksum: "",
            payload: try? WalletPayloadWrapper(string: encryptedPayload)
        )
        walletRepo.set(
            keyPath: \.walletPayload,
            value: walletPayload
        )
        var receivedValue: WalletFetchedContext?
        let expectedValue = WalletFetchedContext(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            sharedKey: "b4a3dcbc-3e85-4cbf-8d0f-e31f9663e888",
            passwordPartHash: "561e1"
        )
        var error: Error?
        let expectation = expectation(description: "wallet-fetching-expectation")

        metadataService.initializeValue = .just(MetadataState.mock)

        walletFetcher.fetch(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            sharedKey: "b4a3dcbc-3e85-4cbf-8d0f-e31f9663e888",
            password: "misura12!"
        )
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let failureError):
                error = failureError
            }
        } receiveValue: { value in
            receivedValue = value
            expectation.fulfill()
        }
        .store(in: &cancellables)

        waitForExpectations(timeout: 10)

        XCTAssertTrue(walletHolder.walletState.value!.isInitialised)
        XCTAssertEqual(receivedValue, expectedValue)
        XCTAssertNil(error)

        XCTAssertTrue(checkAndSaveWalletCredentialsCalled)
        XCTAssertEqual(checkAndSaveWalletCredentialsProperies.guid, expectedValue.guid)
        XCTAssertEqual(checkAndSaveWalletCredentialsProperies.sharedKey, expectedValue.sharedKey)
        XCTAssertEqual(checkAndSaveWalletCredentialsProperies.password, "misura12!")

        // Ensure we send both notification
        XCTAssertTrue(notificationCenterSpy.postNotificationCalled)
        XCTAssertEqual(
            notificationCenterSpy.postNotifications,
            [
                Notification(name: .walletInitialized),
                Notification(name: .walletMetadataLoaded)
            ]
        )
    }
}

class NotificationCenterSpy: NotificationCenter {

    var postNotifications: [Notification] = []
    var postNotificationCalled = false

    override func post(_ notification: Notification) {
        postNotifications.append(notification)
        postNotificationCalled = true
    }
}
