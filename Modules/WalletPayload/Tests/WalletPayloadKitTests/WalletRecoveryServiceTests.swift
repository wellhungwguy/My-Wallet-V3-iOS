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

class WalletRecoveryServiceTests: XCTestCase {

    private let jsonV4 = Fixtures.loadJSONData(filename: "wallet.v4", in: .module)!
    private let jsonV4Wrapper = Fixtures.loadJSONData(filename: "wallet-wrapper-v4", in: .module)!

    private var walletRepo: WalletRepo!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        walletRepo = WalletRepo(initialState: .empty)
        cancellables = []
    }

    func test_wallet_recovery_returns_an_error_on_invalid_seed_phrase() throws {
        let walletHolder = WalletHolder()
        var walletDecoderCalled = false
        let walletDecoder: WalletDecoderAPI = WalletDecoder()
        let decoder: WalletDecoding = { [walletDecoder] walletPayload, blockchainWallet in
            walletDecoderCalled = true
            return walletDecoder.createWallet(from: walletPayload, decryptedData: blockchainWallet)
        }

        let mockMetadata = MetadataServiceMock()
        let walletSync = WalletSyncMock()
        let upgrader = WalletUpgrader(workflows: [])

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            upgrader: upgrader,
            metadata: mockMetadata,
            walletSync: walletSync,
            notificationCenter: .default,
            logger: NoopNativeWalletLogging(),
            payloadHealthChecker: { .just($0) }
        )

        let mockWalletPayloadClient = MockWalletPayloadClient(result: .failure(.from(.unknown)))
        let walletPayloadRepository = WalletPayloadRepository(apiClient: mockWalletPayloadClient)
        let queue = DispatchQueue(label: "temp.recovery.queue")
        let walletRecoveryService = WalletRecoveryService(
            walletLogic: walletLogic,
            payloadCrypto: PayloadCrypto(cryptor: AESCryptor()),
            walletRepo: walletRepo,
            walletPayloadRepository: walletPayloadRepository,
            operationsQueue: queue,
            tracer: LogMessageTracing.noop
        )

        let expectation = expectation(description: "wallet holding")
        let invalidMnemonic = "this is invalid"

        walletRecoveryService.recover(from: invalidMnemonic)
            .sink { completion in
                XCTAssertEqual(completion, .failure(.recovery(.invalidMnemonic)))
                expectation.fulfill()
            } receiveValue: { _ in
                XCTFail("invalid seed phrase should fail")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertFalse(walletDecoderCalled)
    }

    func test_wallet_recovery_returns_correct_value_on_success() throws {
        let walletHolder = WalletHolder()
        var walletDecoderCalled = false
        let walletDecoder: WalletDecoderAPI = WalletDecoder()
        let decoder: WalletDecoding = { [walletDecoder] walletPayload, blockchainWallet in
            walletDecoderCalled = true
            return walletDecoder.createWallet(from: walletPayload, decryptedData: blockchainWallet)
        }

        let mockMetadata = MetadataServiceMock()
        let credentials = Credentials(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            sharedKey: "b4a3dcbc-3e85-4cbf-8d0f-e31f9663e888",
            password: "misura12!"
        )
        mockMetadata.initializeAndRecoverCredentialsValue = .just(
            RecoveryContext(
                metadataState: MetadataState.mock,
                credentials: credentials
            )
        )

        let upgrader = WalletUpgrader(workflows: [])
        let walletSyncMock = WalletSyncMock()

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            upgrader: upgrader,
            metadata: mockMetadata,
            walletSync: walletSyncMock,
            notificationCenter: .default,
            logger: NoopNativeWalletLogging(),
            payloadHealthChecker: { .just($0) }
        )

        let response = WalletPayloadClient.Response(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            authType: 0,
            language: "en",
            serverTime: 0,
            payload: String(data: jsonV4Wrapper, encoding: .utf8)!,
            shouldSyncPubkeys: false,
            payloadChecksum: ""
        )
        let mockWalletPayloadClient = MockWalletPayloadClient(result: .success(response))
        let walletPayloadRepository = WalletPayloadRepository(apiClient: mockWalletPayloadClient)
        let queue = DispatchQueue(label: "temp.recovery.queue")
        let walletRecoveryService = WalletRecoveryService(
            walletLogic: walletLogic,
            payloadCrypto: PayloadCrypto(cryptor: AESCryptor()),
            walletRepo: walletRepo,
            walletPayloadRepository: walletPayloadRepository,
            operationsQueue: queue,
            tracer: LogMessageTracing.noop
        )

        let expectation = expectation(description: "wallet holding")
        // swiftlint:disable:next line_length
        let validMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

        let expectedContext = WalletFetchedContext(
            guid: "dfa6d0af-7b04-425d-b35c-ded8efaa0016",
            sharedKey: "b4a3dcbc-3e85-4cbf-8d0f-e31f9663e888",
            passwordPartHash: "561e1"
        )

        walletRecoveryService
            .recover(from: validMnemonic)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failureError):
                    XCTFail("should not fail: \(failureError)")
                }
            } receiveValue: { value in
                XCTAssertEqual(value, expectedContext)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)

        XCTAssertTrue(walletDecoderCalled)
        XCTAssertEqual(walletRepo.credentials.guid, "dfa6d0af-7b04-425d-b35c-ded8efaa0016")
        XCTAssertEqual(walletRepo.credentials.sharedKey, "b4a3dcbc-3e85-4cbf-8d0f-e31f9663e888")
        XCTAssertEqual(walletRepo.credentials.password, "misura12!")

        XCTAssertEqual(walletRepo.properties.language, "en")
        XCTAssertFalse(walletRepo.properties.syncPubKeys)
        XCTAssertEqual(walletRepo.properties.authenticatorType, WalletAuthenticatorType(rawValue: 0))
    }
}
