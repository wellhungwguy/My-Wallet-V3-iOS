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

class WalletLogicTests: XCTestCase {

    private let jsonV4 = Fixtures.loadJSONData(filename: "wallet.v4", in: .module)!

    private let jsonV3 = Fixtures.loadJSONData(filename: "wallet.v3", in: .module)!

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_wallet_logic_can_initialize_a_wallet() {
        let walletHolder = WalletHolder()
        var decoderWalletCalled = false
        let decoder: WalletDecoding = { payload, data -> AnyPublisher<Wrapper, WalletError> in
            decoderWalletCalled = true
            return WalletDecoder().createWallet(from: payload, decryptedData: data)
        }
        let metadataService = MetadataServiceMock()
        let walletSyncMock = WalletSyncMock()

        let upgrader = WalletUpgrader(workflows: [])

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            upgrader: upgrader,
            metadata: metadataService,
            walletSync: walletSyncMock,
            notificationCenter: .default
        )

        let walletPayload = WalletPayload(
            guid: "guid",
            authType: 0,
            language: "en",
            shouldSyncPubKeys: false,
            time: Date(),
            payloadChecksum: "",
            payload: WalletPayloadWrapper(pbkdf2IterationCount: 5000, version: 4, payload: "") // we don't use this
        )

        metadataService.initializeValue = .just(MetadataState.mock)

        let expectation = expectation(description: "wallet-fetching-expectation")

        walletLogic.initialize(with: "password", payload: walletPayload, decryptedWallet: jsonV4)
            .sink { _ in
                //
            } receiveValue: { _ in
                XCTAssertTrue(decoderWalletCalled)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertTrue(walletHolder.walletState.value!.isInitialised)
    }

    func test_wallet_that_requires_upgrades_is_upgraded_and_synced() {
        let walletHolder = WalletHolder()
        var decoderWalletCalled = false
        let decoder: WalletDecoding = { payload, data -> AnyPublisher<Wrapper, WalletError> in
            decoderWalletCalled = true
            return WalletDecoder().createWallet(from: payload, decryptedData: data)
        }
        let metadataService = MetadataServiceMock()
        let walletSyncMock = WalletSyncMock()

        let upgraderSpy = WalletUpgraderSpy(
            realUpgrader: WalletUpgrader(
                workflows: [Version4Workflow()]
            )
        )

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            upgrader: upgraderSpy,
            metadata: metadataService,
            walletSync: walletSyncMock,
            notificationCenter: .default
        )

        let walletPayload = WalletPayload(
            guid: "guid",
            authType: 0,
            language: "en",
            shouldSyncPubKeys: false,
            time: Date(),
            payloadChecksum: "",
            payload: WalletPayloadWrapper(pbkdf2IterationCount: 5000, version: 3, payload: "") // we don't use this
        )

        metadataService.initializeValue = .just(MetadataState.mock)

        walletSyncMock.syncResult = .success(.noValue)

        let expectation = expectation(description: "wallet-fetching-expectation")

        walletLogic.initialize(with: "password", payload: walletPayload, decryptedWallet: jsonV3)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { walletState in
                    XCTAssertTrue(decoderWalletCalled)
                    // Upgrade should be called
                    XCTAssertTrue(upgraderSpy.upgradedNeededCalled)
                    XCTAssertTrue(upgraderSpy.performUpgradeCalled)
                    // Sync should be called
                    XCTAssertTrue(walletSyncMock.syncCalled)
                    XCTAssertTrue(walletState.isInitialised)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertTrue(walletHolder.walletState.value!.isInitialised)
    }

    func test_wallet_that_requires_upgrades_is_upgraded_but_fails_on_sync_failure() {
        let walletHolder = WalletHolder()
        var decoderWalletCalled = false
        let decoder: WalletDecoding = { payload, data -> AnyPublisher<Wrapper, WalletError> in
            decoderWalletCalled = true
            return WalletDecoder().createWallet(from: payload, decryptedData: data)
        }
        let metadataService = MetadataServiceMock()
        let walletSyncMock = WalletSyncMock()

        let upgraderSpy = WalletUpgraderSpy(
            realUpgrader: WalletUpgrader(
                workflows: [Version4Workflow()]
            )
        )

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            upgrader: upgraderSpy,
            metadata: metadataService,
            walletSync: walletSyncMock,
            notificationCenter: .default
        )

        let walletPayload = WalletPayload(
            guid: "guid",
            authType: 0,
            language: "en",
            shouldSyncPubKeys: false,
            time: Date(),
            payloadChecksum: "",
            payload: WalletPayloadWrapper(pbkdf2IterationCount: 5000, version: 3, payload: "") // we don't use this
        )

        metadataService.initializeValue = .just(MetadataState.mock)

        walletSyncMock.syncResult = .failure(.unknown)

        let expectation = expectation(description: "wallet-fetching-expectation")

        walletLogic.initialize(with: "password", payload: walletPayload, decryptedWallet: jsonV3)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTAssertTrue(decoderWalletCalled)
                    // Upgrade should be called
                    XCTAssertTrue(upgraderSpy.upgradedNeededCalled)
                    XCTAssertTrue(upgraderSpy.performUpgradeCalled)
                    // Sync should be called
                    XCTAssertTrue(walletSyncMock.syncCalled)
                    // we shouldn't have a wallet state
                    XCTAssertNil(walletHolder.provideWalletState())
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("should fail because on syncResult")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
