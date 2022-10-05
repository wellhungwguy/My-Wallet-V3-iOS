// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {
    @ViewBuilder
    public func highlighted() -> some View {
        modifier(HighlightedModifier())
    }
}

private struct HighlightedModifier: ViewModifier {
    func body(content: Content) -> some View {
            content
             .overlay(highlightDot, alignment: .topTrailing)
    }

    private var highlightDot: some View {
        Circle()
            .frame(width: 8, height: 8)
            .foregroundColor(.WalletSemantic.pink)
    }
}
