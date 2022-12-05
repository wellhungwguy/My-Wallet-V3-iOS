// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import SwiftUI
import UIKit

@available(iOS 15.0, *)
struct MultiAppContentView<Content: View>: View {
    let content: Content
    // we might need this for programmatically change the current detent.
    @Binding var selectedDetent: UISheetPresentationController.Detent.Identifier

    init(
        selectedDetent: Binding<UISheetPresentationController.Detent.Identifier>,
        @ViewBuilder content: () -> Content
    ) {
        _selectedDetent = selectedDetent
        self.content = content()
    }

    var body: some View {
        content
    }
}
