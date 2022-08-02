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

// swiftlint:disable line_length
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

        var checkAndSaveWalletCredentialsCalled = false
        let checkAndSaveWalletCredentialsMock: CheckAndSaveWalletCredentials = { _, _, _
-> AnyPublisher<EmptyValue, Never> in
            checkAndSaveWalletCredentialsCalled = true
            return .just(.noValue)
        }

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            upgrader: upgrader,
            metadata: metadataService,
            walletSync: walletSyncMock,
            notificationCenter: .default,
            logger: NoopNativeWalletLogging(),
            payloadHealthChecker: { .just($0) },
            checkAndSaveWalletCredentials: checkAndSaveWalletCredentialsMock
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
                XCTAssertTrue(checkAndSaveWalletCredentialsCalled)
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
                workflows: [Version4Workflow(logger: NoopNativeWalletLogging())]
            )
        )

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            upgrader: upgraderSpy,
            metadata: metadataService,
            walletSync: walletSyncMock,
            notificationCenter: .default,
            logger: NoopNativeWalletLogging(),
            payloadHealthChecker: { .just($0) },
            checkAndSaveWalletCredentials: { _, _, _ in .just(.noValue) }
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
                workflows: [Version4Workflow(logger: NoopNativeWalletLogging())]
            )
        )

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            upgrader: upgraderSpy,
            metadata: metadataService,
            walletSync: walletSyncMock,
            notificationCenter: .default,
            logger: NoopNativeWalletLogging(),
            payloadHealthChecker: { .just($0) },
            checkAndSaveWalletCredentials: { _, _, _ in .just(.noValue) }
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

    func test_metadata_input_is_valid() {
        let entropyHex = "00000000000000000000000000000011"

        let hdWallet = HDWallet(
            seedHex: entropyHex,
            passphrase: "",
            mnemonicVerified: false,
            defaultAccountIndex: 0,
            accounts: []
        )

        let wallet = NativeWallet(
            guid: "802e3bb0-5a4b-4068-bc64-cebb6c3a1917",
            sharedKey: "c5ba92ae-80c8-480b-9347-fc2de641bf68",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [hdWallet],
            addresses: [],
            txNotes: nil,
            addressBook: nil
        )

        let masterNode = getMasterNode(from: wallet).successData!

        let expectedMasterKey = MasterKey.from(masterNode: masterNode).successData!

        provideMetadataInput(
            password: "password",
            wallet: wallet
        )
        .sink { input in
            XCTAssertEqual(
                input.credentials,
                Credentials(guid: wallet.guid, sharedKey: wallet.sharedKey, password: "password")
            )
            XCTAssertEqual(
                input.masterKey,
                expectedMasterKey
            )
        }
        .store(in: &cancellables)
    }

    func test_integration_generate_nodes_for_new_account() {

        let expectedRootAddress = "1Bz8SGpLXrMf12q6atKFoSrkuwCCevvabL"

        var fetchCalled = false
        let fetchMock: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedRootAddress)
            fetchCalled = true
            return .just(
                MetadataPayload(
                    version: 1,
                    payload: "",
                    signature: "",
                    prevMagicHash: nil,
                    typeId: -1,
                    createdAt: 0,
                    updatedAt: 0,
                    address: address
                )
            )
        }

        var putCalled = false
        let putMock: PutMetadataEntry = { address, _ in
            putCalled = true
            XCTAssertEqual(address, expectedRootAddress)
            return .just(())
        }

        let entropyHex = "00000000000000000000000000000000"

        let hdWallet = HDWallet(
            seedHex: entropyHex,
            passphrase: "",
            mnemonicVerified: false,
            defaultAccountIndex: 0,
            accounts: []
        )

        let wallet = NativeWallet(
            guid: "802e3bb0-5a4b-4068-bc64-cebb6c3a1917",
            sharedKey: "c5ba92ae-80c8-480b-9347-fc2de641bf68",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [hdWallet],
            addresses: [],
            txNotes: nil,
            addressBook: nil
        )

        let generateNodes = provideGenerateNodes(
            fetch: fetchMock,
            put: putMock
        )

        provideMetadataInput(
            password: "Misura12!",
            wallet: wallet
        )
        .eraseError()
        .flatMap { input -> AnyPublisher<(MetadataState, MetadataInput), Error> in
            deriveSecondPasswordNode(credentials: input.credentials)
                .publisher
                .eraseError()
                .eraseToAnyPublisher()
                .flatMap { secondPasswordNode -> AnyPublisher<MetadataState, Error> in
                    generateNodes(input.masterKey, secondPasswordNode)
                        .eraseError()
                        .eraseToAnyPublisher()
                }
                .map { ($0, input) }
                .eraseToAnyPublisher()
        }
        .sink { state, input in
            // This is the BIP32 Root Key for the given entropy
            XCTAssertTrue(fetchCalled)
            XCTAssertTrue(putCalled)

            XCTAssertEqual(
                input.masterKey.privateKey.xpriv,
                "xprv9s21ZrQH143K3GJpoapnV8SFfukcVBSfeCficPSGfubmSFDxo1kuHnLisriDvSnRRuL2Qrg5ggqHKNVpxR86QEC8w35uxmGoggxtQTPvfUu"
            )
            // This should be the root PrivateKey for metadata derivation
            // m/{purpose}' where {purpose} is defined in `MetadataDerivation` on `MetadataKit`
            XCTAssertEqual(
                state.metadataNodes.metadataNode.xpriv,
                "xprv9ukW2UsuzBb5WY6LimMwFSSaTNBQAZVhsdeWNshKUH1FXxoiAVE9HHKbk5Ppu8C3Ns8eDT8mF5xhjmBrYLF6NHgguXTrxXTXe66FeYPKBCy"
            )
        }
        .store(in: &cancellables)
    }
}
