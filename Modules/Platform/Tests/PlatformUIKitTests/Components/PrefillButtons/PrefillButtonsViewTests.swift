// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformUIKit

import ComposableArchitecture
import MoneyKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PrefillButtonsViewTests: XCTestCase {
    func test_PrefillButtonsView() {
        let prefillButtonsView = PrefillButtonsView(
            store: Store<PrefillButtonsState, PrefillButtonsAction>(
                initialState: PrefillButtonsState(
                    baseValue: FiatValue(amount: 5000, currency: .USD),
                    maxLimit: FiatValue(amount: 120000, currency: .USD)
                ),
                reducer: prefillButtonsReducer,
                environment: .preview
            )
        )
        .frame(width: 375, height: 60)

        assertSnapshot(matching: prefillButtonsView, as: .image, record: false)
    }
}
