@testable import BlockchainComponentLibrary
import SnapshotTesting
import SwiftUI
import XCTest

final class BalanceRowTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSnapshot() {
        let view = VStack(spacing: Spacing.baseline) {
            BalanceRow_Previews.previews
        }
        .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
