// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension View {
    @ViewBuilder
    public func highlighted(_ highlighted: Bool) -> some View {
        modifier(HighlightedModifier(isHighlighted: highlighted))
    }
}

private struct HighlightedModifier: ViewModifier {
    let isHighlighted: Bool
    func body(content: Content) -> some View {
        if isHighlighted {
            content
                .overlay(highlightDot, alignment: .topTrailing)
        }
    }

    private var highlightDot: some View {
        Circle()
            .frame(width: 8, height: 8)
            .foregroundColor(.WalletSemantic.pink)
    }
}
