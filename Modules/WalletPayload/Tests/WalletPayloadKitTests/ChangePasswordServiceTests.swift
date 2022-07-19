@testable import MetadataKit
@testable import MetadataKitMock
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock

import Combine
import TestKit
import ToolKit
import XCTest

class ChangePasswordServiceTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_change_password_works_correctly() {
        let walletHolderSpy = WalletHolderSpy(spyOn: WalletHolder())
        let walletSync = WalletSyncMock()

        // given
        let service = ChangePasswordService(
            walletSync: walletSync,
            walletHolder: walletHolderSpy,
            logger: NoopNativeWalletLogging()
        )

        let expectation = expectation(description: "change password should succeed")

        // when
        let wallet = NativeWallet(
            guid: "guid",
            sharedKey: "sharedKey",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [],
            addresses: [],
            txNotes: nil,
            addressBook: nil
        )
        let wrapper = Wrapper(
            pbkdf2Iterations: 5000,
            version: 4,
            payloadChecksum: "",
            language: "en",
            syncPubKeys: false,
            wallet: wallet
        )

        walletHolderSpy.hold(walletState: .loaded(wrapper: wrapper, metadata: MetadataState.mock))
            .subscribe()
            .store(in: &cancellables)

        walletSync.syncResult = .success(.noValue)

        service.change(password: "new-password")
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { _ in
                    XCTAssertTrue(walletHolderSpy.walletStatePublisherCalled)
                    XCTAssertTrue(walletSync.syncCalled)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
