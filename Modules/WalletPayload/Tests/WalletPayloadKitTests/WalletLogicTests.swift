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
    private let jsonV4Broken = Fixtures.loadJSONData(filename: "wallet.v4.broken", in: .module)!

    private let jsonV4InvalidAddressCache = Fixtures.loadJSONData(filename: "wallet.v4.broken_addressCache", in: .module)!

    private let jsonV3 = Fixtures.loadJSONData(filename: "wallet.v3", in: .module)!

    private var cancellables: Set<AnyCancellable>!

    private let walletHolder = WalletHolder()

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_wallet_logic_can_initialize_a_wallet() {

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
            checkAndSaveWalletCredentials: checkAndSaveWalletCredentialsMock,
            derivationReplenishement: { wrapper, _ in .just(wrapper) }
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

    func test_broken_wallet_payload_can_be_decoded_replenished() {
        let walletHolder = WalletHolder()
        var decoderWalletCalled = false
        let decoder: WalletDecoding = { payload, data -> AnyPublisher<Wrapper, WalletError> in
            decoderWalletCalled = true
            return WalletDecoder().createWallet(from: payload, decryptedData: data)
        }
        let metadataService = MetadataServiceMock()
        let walletSyncMock = WalletSyncMock()

        let upgrader = WalletUpgrader(workflows: [])

        var runDerivationsReplenishementCalled = false
        let runDerivationsReplenishementSpy: DerivationReplenishement = { wrapper, logger -> AnyPublisher<Wrapper, WalletError> in
            runDerivationsReplenishementCalled = true
            return runDerivationsReplenishement(wrapper: wrapper, logger: logger)
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
            checkAndSaveWalletCredentials: { _, _, _ in .just(.noValue) },
            derivationReplenishement: runDerivationsReplenishementSpy
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
                    XCTAssertTrue(runDerivationsReplenishementCalled)

                    XCTAssertTrue(walletState.wallet!.defaultHDWallet?.accounts.count == 1)
                    XCTAssertTrue(
                        walletState.wallet!.defaultHDWallet?.accounts.first?.derivations.count == DerivationType.defaultDerivations.count
                    )
                    XCTAssertTrue(walletState.isInitialised)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)

        XCTAssertTrue(walletHolder.walletState.value!.isInitialised)
    }

    func test_broken_derivation_account_cache_can_be_replenished() {
        let walletHolder = WalletHolder()
        var decoderWalletCalled = false
        let decoder: WalletDecoding = { payload, data -> AnyPublisher<Wrapper, WalletError> in
            decoderWalletCalled = true
            return WalletDecoder().createWallet(from: payload, decryptedData: data)
        }
        let metadataService = MetadataServiceMock()
        let walletSyncMock = WalletSyncMock()

        let upgrader = WalletUpgrader(workflows: [])

        var runDerivationsReplenishementCalled = false
        let runDerivationsReplenishementSpy: DerivationReplenishement = { wrapper, logger -> AnyPublisher<Wrapper, WalletError> in
            runDerivationsReplenishementCalled = true
            return runDerivationsReplenishement(wrapper: wrapper, logger: logger)
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
            checkAndSaveWalletCredentials: { _, _, _ in .just(.noValue) },
            derivationReplenishement: runDerivationsReplenishementSpy
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

        walletSyncMock.syncResult = .success(.noValue)

        let expectation = expectation(description: "wallet-fetching-expectation")

        let expectedDerivations = [
            Derivation(
                type: .legacy,
                purpose: DerivationType.legacy.purpose,
                xpriv: "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG",
                xpub: "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3",
                addressLabels: [.init(index: 0, label: "labeled_address")],
                cache: AddressCache(
                    receiveAccount: "xpub6F41z8MqNcJMvKQgAd5QE2QYo32cocYigWp1D8726ykMmaMqvtqLkvuL1NqGuUJvU3aWyJaV2J4V6sD7Pv59J3tYGZdYRSx8gU7EG8ZuPSY",
                    changeAccount: "xpub6F41z8MqNcJMwmeUExdCv7UXvYBEgQB29SWq9jyxuZ7WefmSTWcwXB6NRAJkGCkB3L1Eu4ttzWnPVKZ6REissrQ4i6p8gTi9j5YwDLxmZ8p"
                )
            ),
            Derivation(
                type: .segwit,
                purpose: DerivationType.segwit.purpose,
                xpriv: "xprv9xyd6QiiJ9PHLpoaGZ1J2ZAit27rMoZBsg7pGfZu18Y9KYyeVsbF7fqFoKYD1yVvALxSUeLCD3LGxfk5kPPNQhx1P57ukDfoKRDqjEFTvYT",
                xpub: "xpub6BxyVvFc8WwaZJt3NaYJPh7TS3xLmGH3Eu3R53yWZU58CMJo3QuVfU9jedpAuVA1idn7tJX6TrLVpeifbAySPewVEdH52tSQchLwSznnyCY",
                addressLabels: [.init(index: 0, label: "labeled_address")],
                cache: AddressCache(
                    receiveAccount: "xpub6EMzXNjqSJ9cwWWPhVjN9EaRnjgaYXwg8WMRcXc9SgP5RpUCFFkDwbqJoAdzBkRCQZB5AA9qh3zk8uEpyzfUDGrXGE23GnCFGoPuYVMTN6C",
                    changeAccount: "xpub6EMzXNjqSJ9czvz8pyajFSziPmvSFvhukW8T48jvWs1Zxq9aTDqhfbNzz6DnzkdnvRSxXBBcw4APsbEcsFbFF9zqU8cznBasHhijkrUVnnK"
                )
            )
        ]

        // given an with broken address cache on derivation, it should be replenished
        walletLogic.initialize(with: "password", payload: walletPayload, decryptedWallet: jsonV4InvalidAddressCache)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { walletState in
                    XCTAssertTrue(decoderWalletCalled)
                    XCTAssertTrue(runDerivationsReplenishementCalled)

                    XCTAssertTrue(walletState.wallet!.defaultHDWallet?.accounts.count == 1)
                    XCTAssertNotNil(walletState.wallet!.defaultHDWallet)
                    let account = walletState.wallet!.defaultHDWallet!.accounts.first
                    XCTAssertNotNil(account)
                    XCTAssertTrue(
                        account!.derivations == expectedDerivations
                    )
                    XCTAssertTrue(walletState.isInitialised)
                    expectation.fulfill()
                }
            )
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
            checkAndSaveWalletCredentials: { _, _, _ in .just(.noValue) },
            derivationReplenishement: { _, _ in .failure(.unknown) }
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
            checkAndSaveWalletCredentials: { _, _, _ in .just(.noValue) },
            derivationReplenishement: { _, _ in .failure(.unknown) }
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

        let masterNode = getMasterNode(from: wallet).success!

        let expectedMasterKey = MasterKey.from(masterNode: masterNode).success!

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
