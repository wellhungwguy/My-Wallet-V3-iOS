// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SnapshotTesting
import XCTest

final class IconButtonTexts: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    let button = IconButton(icon: .qrCode) {}

    func testDefault() {
        assertSnapshot(matching: button, as: .image)
    }

    func testDisabled() {
        assertSnapshot(matching: button.disabled(true), as: .image)
    }

    func testCircle() {
        let button = IconButton(icon: .qrCode.circle()) {}.frame(width: 32, height: 32)
        assertSnapshot(matching: button, as: .image)
    }
}
