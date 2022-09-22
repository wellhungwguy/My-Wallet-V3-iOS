// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureCheckoutUI

import SnapshotTesting
import SwiftUI
import XCTest

final class SwapCheckoutViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func test_SwapCheckoutView() {
        let coinView = SwapCheckoutView(
            swapCheckoutPublisher: .just(.preview),
            onStatusChange: { _ in }
        )
        assertSnapshot(
            matching: coinView,
            as: .image(layout: .device(config: .iPhone8))
        )
    }

    func test_SwapCheckoutView_expanded() {
        let coinView = SwapCheckoutView(
            swapCheckoutPublisher: .just(.preview),
            showExchangeRateDisclaimer: true,
            showFeeDetails: true,
            onStatusChange: { _ in }
        )
        assertSnapshot(
            matching: coinView,
            as: .image(layout: .device(config: .iPhone8))
        )
    }
}
