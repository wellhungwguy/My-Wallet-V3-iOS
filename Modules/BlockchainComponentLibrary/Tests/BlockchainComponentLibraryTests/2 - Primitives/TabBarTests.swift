// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

final class TabBarTests: XCTestCase {

    let wallet = TabBar_Previews.WalletPreviewContainer(
        activeTabIdentifier: TabBar_Previews.WalletPreviewContainer.Tab.home,
        fabIsActive: false
    )

    let exchange = TabBar_Previews.ExchangePreviewContainer(
        activeTabIdentifier: TabBar_Previews.ExchangePreviewContainer.Tab.home
    )

    func testWallet_iPhone8() {
        assertSnapshots(
            matching: wallet,
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }

    func testExchange_iPhone8() {
        assertSnapshots(
            matching: exchange,
            as: [
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .device(config: .iPhone8), traits: UITraitCollection(userInterfaceStyle: .dark))
            ],
            record: false
        )
    }
}
