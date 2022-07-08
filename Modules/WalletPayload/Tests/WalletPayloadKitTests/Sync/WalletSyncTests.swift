// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
@testable import MetadataKitMock
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock

import Combine
import Errors
import TestKit
import ToolKit
import XCTest

class WalletSyncTests: XCTestCase {

    var walletHolder: WalletHolder!
    var walletRepo: WalletRepo!
    var saveWalletRepositoryMock: SaveWalletRepositoryMock!
    var payloadCryptoMock: MockPayloadCrypto!
    var mockWalletEncoder: MockWalletEncoder!

    var applyChecksum: ((Data) -> String)!

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        walletHolder = WalletHolder()
        walletRepo = WalletRepo(initialState: .empty)
        saveWalletRepositoryMock = SaveWalletRepositoryMock()
        payloadCryptoMock = MockPayloadCrypto()
        applyChecksum = { _ in "checksum" }
        mockWalletEncoder = MockWalletEncoder()
    }

    func test_sync_saves_correctly_and_updates_state() {

        walletRepo.set(keyPath: \.credentials.password, value: "password")

        saveWalletRepositoryMock.saveWalletResult = .success(())

        let wallet = NativeWallet(
            guid: "guid",
            sharedKey: "shared-key",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [],
            addresses: []
        )
        let wrapper = Wrapper(
            pbkdf2Iterations: 1,
            version: 4,
            payloadChecksum: "",
            language: "en",
            syncPubKeys: false,
            wallet: wallet
        )

        walletHolder.hold(walletState: .partially(loaded: .justWrapper(wrapper)))
            .subscribe()
            .store(in: &cancellables)

        mockWalletEncoder.transformValue = .just(
            EncodedWalletPayload(
                payloadContext: .encoded("".data(using: .utf8)!),
                wrapper: wrapper
            )
        )

        mockWalletEncoder.encodeValue = .just(
            WalletCreationPayload(
                data: "".data(using: .utf8)!,
                wrapper: wrapper,
                applyChecksum: applyChecksum
            )
        )

        payloadCryptoMock.encryptDataResult = .success("")
        payloadCryptoMock.decryptWalletBase64StringResult = .success("")

        let syncPubKeysAddressesProviderMock = SyncPubKeysAddressesProviderMock()

        let walletSync = WalletSync(
            walletHolder: walletHolder,
            walletRepo: walletRepo,
            payloadCrypto: payloadCryptoMock,
            walletEncoder: mockWalletEncoder,
            saveWalletRepository: saveWalletRepositoryMock,
            syncPubKeysAddressesProvider: syncPubKeysAddressesProviderMock,
            operationQueue: DispatchQueue.main,
            checksumProvider: applyChecksum
        )

        let expectedWrapper = Wrapper(
            pbkdf2Iterations: Int(wrapper.pbkdf2Iterations),
            version: wrapper.version,
            payloadChecksum: "checksum",
            language: wrapper.language,
            syncPubKeys: wrapper.syncPubKeys,
            wallet: wallet
        )

        let expectation = expectation(description: "should sync a wallet")

        // pass a new password to verify we're updating the password
        let newPassword = "new-password"

        walletSync.sync(wrapper: wrapper, password: newPassword)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else {
                        return
                    }
                    XCTFail("should not fail: \(error)")
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    // verify encrypt/decrypt were called
                    XCTAssertTrue(self.payloadCryptoMock.encryptDataCalled)
                    XCTAssertTrue(self.payloadCryptoMock.decryptWalletBase64StringCalled)
                    // verify encoding methods called
                    XCTAssertTrue(self.mockWalletEncoder.encodePayloadCalled)
                    XCTAssertTrue(self.mockWalletEncoder.transformWrapperCalled)

                    // verify save for backend were called
                    XCTAssertTrue(self.saveWalletRepositoryMock.saveWalletCalled)

                    // verify password updated, if needed
                    XCTAssertEqual(self.walletRepo.credentials.password, newPassword)

                    // verify wrapper was updated (checksum)
                    let state = self.walletHolder.provideWalletState()
                    XCTAssertEqual(state!, .partially(loaded: .justWrapper(expectedWrapper)))
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

    func test_sync_saves_correctly_and_updates_state_with_sync_pub_keys() {

        walletRepo.set(keyPath: \.credentials.password, value: "password")

        saveWalletRepositoryMock.saveWalletResult = .success(())

        let wallet = NativeWallet(
            guid: "guid",
            sharedKey: "shared-key",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [],
            addresses: []
        )
        let wrapper = Wrapper(
            pbkdf2Iterations: 1,
            version: 4,
            payloadChecksum: "",
            language: "en",
            syncPubKeys: true,
            wallet: wallet
        )

        walletHolder.hold(walletState: .partially(loaded: .justWrapper(wrapper)))
            .subscribe()
            .store(in: &cancellables)

        mockWalletEncoder.transformValue = .just(
            EncodedWalletPayload(
                payloadContext: .encoded("".data(using: .utf8)!),
                wrapper: wrapper
            )
        )

        mockWalletEncoder.encodeValue = .just(
            WalletCreationPayload(
                data: "".data(using: .utf8)!,
                wrapper: wrapper,
                applyChecksum: applyChecksum
            )
        )

        payloadCryptoMock.encryptDataResult = .success("")
        payloadCryptoMock.decryptWalletBase64StringResult = .success("")

        let syncPubKeysAddressesProviderMock = SyncPubKeysAddressesProviderMock()
        let addresses = "some_address_1|some_address_2"
        syncPubKeysAddressesProviderMock.provideAddressesResult = .success(addresses)

        let walletSync = WalletSync(
            walletHolder: walletHolder,
            walletRepo: walletRepo,
            payloadCrypto: payloadCryptoMock,
            walletEncoder: mockWalletEncoder,
            saveWalletRepository: saveWalletRepositoryMock,
            syncPubKeysAddressesProvider: syncPubKeysAddressesProviderMock,
            operationQueue: DispatchQueue.main,
            checksumProvider: applyChecksum
        )

        let expectedWrapper = Wrapper(
            pbkdf2Iterations: Int(wrapper.pbkdf2Iterations),
            version: wrapper.version,
            payloadChecksum: "checksum",
            language: wrapper.language,
            syncPubKeys: wrapper.syncPubKeys,
            wallet: wallet
        )

        let expectation = expectation(description: "should sync a wallet")

        // pass a new password to verify we're updating the password
        let newPassword = "new-password"

        walletSync.sync(wrapper: wrapper, password: newPassword)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else {
                        return
                    }
                    XCTFail("should not fail: \(error)")
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    // verify encrypt/decrypt were called
                    XCTAssertTrue(self.payloadCryptoMock.encryptDataCalled)
                    XCTAssertTrue(self.payloadCryptoMock.decryptWalletBase64StringCalled)
                    // verify encoding methods called
                    XCTAssertTrue(self.mockWalletEncoder.encodePayloadCalled)
                    XCTAssertTrue(self.mockWalletEncoder.transformWrapperCalled)

                    // verify syncPubKeys called
                    XCTAssertTrue(syncPubKeysAddressesProviderMock.provideAddressesCalled)

                    // verify save for backend were called
                    XCTAssertTrue(self.saveWalletRepositoryMock.saveWalletCalled)
                    XCTAssertEqual(self.saveWalletRepositoryMock.addresses, addresses)

                    // verify password updated, if needed
                    XCTAssertEqual(self.walletRepo.credentials.password, newPassword)

                    // verify wrapper was updated (checksum)
                    let state = self.walletHolder.provideWalletState()
                    XCTAssertEqual(state!, .partially(loaded: .justWrapper(expectedWrapper)))
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
