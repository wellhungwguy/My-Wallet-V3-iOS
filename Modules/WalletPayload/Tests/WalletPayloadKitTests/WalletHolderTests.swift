// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class WalletHolderTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_initializing_wallet_holder_should_provide_wallet_nil() {
        let holder = WalletHolder()
        XCTAssertNil(holder.walletState.value)
        XCTAssertNil(holder.provideWalletState())
    }

    func test_wallet_holder_can_hold_partial_state() {
        let holder = WalletHolder()
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

        let expectation = expectation(description: "wallet holding")
        holder.hold(walletState: .partially(loaded: .justWrapper(wrapper)))
            .sink { _ in
                //
            } receiveValue: { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)

        XCTAssertNotNil(holder.walletState.value)
        XCTAssertFalse(holder.walletState.value!.isInitialised)
    }

    func test_wallet_holder_can_release_an_previous_created_wallet_object() {
        let holder = WalletHolder()
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

        let expectation = expectation(description: "wallet holding")
        holder.hold(walletState: .partially(loaded: .justWrapper(wrapper)))
            .sink { _ in
                //
            } receiveValue: { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)

        XCTAssertNotNil(holder.walletState.value)

        // when
        holder.release()

        // then
        XCTAssertNil(holder.walletState.value)
    }
}
