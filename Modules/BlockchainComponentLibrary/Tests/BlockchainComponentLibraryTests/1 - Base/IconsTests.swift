// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

final class IconsTests: XCTestCase {

//    func testIcons() {
//        let view = Icon_Previews.previews
//
//        assertSnapshots(
//            matching: view,
//            as: [
//                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
//                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
//            ],
//            record: false
//        )
//    }

    func testScaling() {
        let view = Icon.send.frame(width: 200, height: 200)

        assertSnapshot(matching: view, as: .image, record: false)

        let smaller = Icon.send.frame(width: 10, height: 10)

        assertSnapshot(matching: smaller, as: .image, record: false)
    }

    func testColoring() {
        let view = Icon.send.accentColor(.green)

        assertSnapshot(matching: view, as: .image, record: false)
    }

//    func testCircle() {
//        let view = Icon.walletSwap.circle().frame(width: 32, height: 32)
//
//        assertSnapshot(matching: view, as: .image, record: false)
//    }
}
