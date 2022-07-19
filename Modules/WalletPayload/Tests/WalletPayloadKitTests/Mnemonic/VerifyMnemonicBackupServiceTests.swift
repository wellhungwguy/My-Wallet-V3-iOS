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

class VerifyMnemonicBackupServiceTests: XCTestCase {

    private let jsonV4 = Fixtures.loadJSONData(filename: "wallet.v4", in: .module)!

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_can_update_and_sync_mnemonic_verification() throws {
        let walletHolder = WalletHolder()
        let walletRepo = WalletRepo(initialState: .empty)
        let walletSync = WalletSyncMock()

        // Given
        let verifyMnemonicBackupService = VerifyMnemonicBackupService(
            walletHolder: walletHolder,
            walletSync: walletSync,
            walletRepo: walletRepo,
            logger: NoopNativeWalletLogging()
        )

        // When
        let walletResponse = try JSONDecoder().decode(WalletResponse.self, from: jsonV4)
        let nativeWallet = NativeWallet.from(blockchainWallet: walletResponse)
        let wrapper = Wrapper(
            pbkdf2Iterations: 0,
            version: 0,
            payloadChecksum: "",
            language: "",
            syncPubKeys: false,
            wallet: nativeWallet
        )
        walletHolder.hold(walletState: .loaded(wrapper: wrapper, metadata: MetadataState.mock))
            .subscribe()
            .store(in: &cancellables)
        walletRepo.set(keyPath: \.credentials.password, value: "password")

        walletSync.syncResult = .success(.noValue)

        let expectation = expectation(description: "mnemonic verification syncing")

        verifyMnemonicBackupService.markRecoveryPhraseAndSync()
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { _ in
                    XCTAssertTrue(walletSync.syncCalled)
                    // verify that the passed `Wrapper` has been updated
                    XCTAssertNotEqual(walletSync.givenWrapper, wrapper)
                    XCTAssertTrue(walletSync.givenWrapper!.wallet.defaultHDWallet!.mnemonicVerified)
                    XCTAssertEqual(walletSync.givenPassword, "password")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
