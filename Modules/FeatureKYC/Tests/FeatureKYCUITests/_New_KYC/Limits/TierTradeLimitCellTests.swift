// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureKYCUI
import SnapshotTesting
import XCTest

final class TierTradeLimitCellTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func test_contents_for_tier_1() throws {
        let view = TierTradeLimitCell(tier: .tier1)
            .frame(width: 320)
            .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }

    func test_contents_for_tier_2() throws {
        let view = TierTradeLimitCell(tier: .tier2)
            .frame(width: 320)
            .fixedSize()

        assertSnapshots(
            matching: view,
            as: [
                .image(traits: UITraitCollection(userInterfaceStyle: .light)),
                .image(traits: UITraitCollection(userInterfaceStyle: .dark))
            ]
        )
    }
}
