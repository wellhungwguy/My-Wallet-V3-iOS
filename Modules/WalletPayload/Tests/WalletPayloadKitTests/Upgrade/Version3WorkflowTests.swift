// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class Version3WorkflowTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_upgrade_from_version_2_to_3_works_correctly() {
        // dummy decoded object on our end for a v2 wallet
        let version2Wrapper = Wrapper(
            pbkdf2Iterations: 5000,
            version: 2,
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
                hdWallets: [],
                addresses: []
            )
        )

        let mockServerEntropy = MockServerEntropyRepository()
        mockServerEntropy.serverEntropyResult = .success("00000000000000000000000000000011")
        let rngService = RNGService(
            serverEntropyRepository: mockServerEntropy,
            localEntropyProvider: { _ in .just(Data(hex: "00000000000000000000000000000001")) },
            operationQueue: DispatchQueue(label: "rng.service.op.queue")
        )

        let expectation = expectation(description: "should perform workflows")

        let workflow = Version3Workflow(
            entropyService: rngService,
            operationQueue: .main
        )

        workflow.upgrade(wrapper: version2Wrapper)
            .sink(receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide correct value")
            }, receiveValue: { wrapper in
                XCTAssertFalse(wrapper.wallet.hdWallets.isEmpty)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }
}
