// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

// swiftlint:disable line_length
class Version4WorkflowTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_upgrade_from_version_3_to_4_works_correctly() throws {
        // dummy decoded object on our end for a v3 wallet
        let hdWalletV3 = HDWallet(
            seedHex: "6a4d9524d413fdf69ca1b5664d1d6db0",
            passphrase: "",
            mnemonicVerified: false,
            defaultAccountIndex: 0,
            accounts: [
                .init(
                    index: 0,
                    label: "",
                    archived: false,
                    defaultDerivation: .legacy,
                    derivations: [
                        .init(
                            type: .legacy,
                            purpose: 44,
                            xpriv: "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG",
                            xpub: "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3",
                            addressLabels: [],
                            cache: .init(receiveAccount: "", changeAccount: "")
                        )
                    ]
                )
            ]
        )
        let version3Wrapper = Wrapper(
            pbkdf2Iterations: 5000,
            version: 3,
            payloadChecksum: "",
            language: "",
            syncPubKeys: false,
            wallet: NativeWallet(
                guid: "guid",
                sharedKey: "sharedKey",
                doubleEncrypted: false,
                doublePasswordHash: nil,
                metadataHDNode: nil,
                txNotes: nil,
                tagNames: nil,
                options: .default,
                hdWallets: [hdWalletV3],
                addresses: []
            )
        )

        let expectation = expectation(description: "should perform workflows")

        let expectedSegwitXpriv = "xprv9xyd6QiiJ9PHLpoaGZ1J2ZAit27rMoZBsg7pGfZu18Y9KYyeVsbF7fqFoKYD1yVvALxSUeLCD3LGxfk5kPPNQhx1P57ukDfoKRDqjEFTvYT"
        let expectedSegwitXpub = "xpub6BxyVvFc8WwaZJt3NaYJPh7TS3xLmGH3Eu3R53yWZU58CMJo3QuVfU9jedpAuVA1idn7tJX6TrLVpeifbAySPewVEdH52tSQchLwSznnyCY"

        let workflow = Version4Workflow()

        workflow.upgrade(wrapper: version3Wrapper)
            .sink(receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide correct value")
            }, receiveValue: { wrapper in
                XCTAssertFalse(wrapper.wallet.hdWallets.isEmpty)
                XCTAssertNotNil(wrapper.wallet.defaultHDWallet)
                XCTAssertNotNil(wrapper.wallet.defaultHDWallet!.accounts.first)
                let account = wrapper.wallet.defaultHDWallet!.accounts.first
                let derivations = account!.derivations
                XCTAssertEqual(derivations.count, 2)
                let legacyDerivation = account!.derivation(for: .legacy)!
                let segwitDerivation = account!.derivation(for: .segwit)!
                XCTAssertEqual(
                    legacyDerivation.xpriv,
                    "xprv9yL1ousLjQQzGNBAYykaT8J3U626NV6zbLYkRv8rvUDpY4f1RnrvAXQneGXC9UNuNvGXX4j6oHBK5KiV2hKevRxY5ntis212oxjEL11ysuG"
                )
                XCTAssertEqual(
                    legacyDerivation.xpub,
                    "xpub6CKNDRQEZmyHUrFdf1HapGEn27ramwpqxZUMEJYUUokoQrz9yLBAiKjGVWDuiCT39udj1r3whqQN89Tar5KrojH8oqSy7ytzJKW8gwmhwD3"
                )
                XCTAssertEqual(
                    segwitDerivation.xpriv,
                    expectedSegwitXpriv
                )
                XCTAssertEqual(
                    segwitDerivation.xpub,
                    expectedSegwitXpub
                )
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
