// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class WalletUpgraderTests: XCTestCase {

    var tempWrapper: Wrapper!

    var tempWallet = NativeWallet(
        guid: "",
        sharedKey: "",
        doubleEncrypted: false,
        doublePasswordHash: "",
        metadataHDNode: "",
        txNotes: nil,
        tagNames: nil,
        options: .default,
        hdWallets: [],
        addresses: []
    )

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
        tempWrapper = Wrapper(walletPayload: .empty, wallet: tempWallet)
    }

    func test_upgrade_workflow_works_correctly() {
        let firstWorkflow = provideWorkflow(version: .v3, shouldPerformUpgrade: true, wallet: tempWallet)
        let secondWorkflow = provideWorkflow(version: .v4, shouldPerformUpgrade: true, wallet: tempWallet)
        let upgrader = WalletUpgrader(
            workflows: [firstWorkflow, secondWorkflow]
        )

        let expectation = expectation(description: "should perform workflows")

        upgrader.performUpgrade(wrapper: tempWrapper)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { wrapper in
                    XCTAssertTrue(firstWorkflow.upgradedWrapperCalled)
                    XCTAssertTrue(secondWorkflow.upgradedWrapperCalled)
                    XCTAssertEqual(wrapper.version, 4)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_upgrade_workflow_ignores_non_needed_upgrade_flow() {
        let firstWorkflowToBeIgnored = provideWorkflow(
            version: .v3,
            shouldPerformUpgrade: false,
            wallet: tempWallet
        )
        let secondWorkflow = provideWorkflow(
            version: .v4,
            shouldPerformUpgrade: true,
            wallet: tempWallet
        )
        let upgrader = WalletUpgrader(
            workflows: [firstWorkflowToBeIgnored, secondWorkflow]
        )

        let expectation = expectation(description: "should perform workflows")

        upgrader.performUpgrade(wrapper: tempWrapper)
            .sink(
                receiveCompletion: { completion in
                    guard case .failure = completion else {
                        return
                    }
                    XCTFail("should provide correct value")
                },
                receiveValue: { wrapper in
                    // it should not call the first workflow
                    XCTAssertFalse(firstWorkflowToBeIgnored.upgradedWrapperCalled)
                    // but only call the second workflow
                    XCTAssertTrue(secondWorkflow.upgradedWrapperCalled)
                    XCTAssertEqual(wrapper.version, 4)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }
}

private func provideWorkflow(
    version: WalletPayloadVersion,
    shouldPerformUpgrade: Bool,
    wallet: NativeWallet
) -> MockWorkflow {
    let workflow = MockWorkflow()
    workflow.performUpgrade = shouldPerformUpgrade
    workflow.upgradedWrapper = Wrapper(
        pbkdf2Iterations: 0,
        version: version.rawValue,
        payloadChecksum: "",
        language: "",
        syncPubKeys: false,
        wallet: wallet
    )
    return workflow
}

private class MockWorkflow: WalletUpgradeWorkflow {
    static var supportedVersion: WalletPayloadVersion = .v3

    var performUpgradeCalled = false
    var performUpgrade = false
    func shouldPerformUpgrade(wrapper: Wrapper) -> Bool {
        performUpgradeCalled = true
        return performUpgrade
    }

    var upgradedWrapper: Wrapper?
    var upgradedWrapperCalled = false
    func upgrade(wrapper: Wrapper) -> AnyPublisher<Wrapper, WalletUpgradeError> {
        guard let upgradedWrapper = upgradedWrapper else {
            return .failure(.upgradeFailed)
        }
        upgradedWrapperCalled = true
        return .just(upgradedWrapper)
            .eraseToAnyPublisher()
    }
}
