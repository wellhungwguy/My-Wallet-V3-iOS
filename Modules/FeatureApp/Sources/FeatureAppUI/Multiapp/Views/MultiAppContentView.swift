// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct MultiAppContentView<Content: View>: View {
    let content: Content
    @Binding var scrollOffset: CGPoint
    // we might need this for programmatically change the current detent.
    @Binding var selectedDetent: PresentationDetent

    @State private var _uiScrollView: UIScrollView?
    // swiftlint:disable weak_delegate
    @StateObject private var scrollViewDelegate = MultiAppScrollViewDelegate()

    init(
        scrollOffset: Binding<CGPoint>,
        selectedDetent: Binding<PresentationDetent>,
        @ViewBuilder content: () -> Content
    ) {
        _scrollOffset = scrollOffset
        _selectedDetent = selectedDetent
        self.content = content()
    }

    var body: some View {
        content
            .findScrollView { scrollView in
                scrollView.delegate = scrollViewDelegate
                scrollViewDelegate.didScroll = { _ in
                    // no-op do we need this? hmm
                }
                scrollViewDelegate.didEndDragging = { _ in
//                    selectedDetent = .collapsed
                }
                self._uiScrollView = scrollView
            }
    }
}

struct StaticMultiAppContentView<Content: View>: View {
    let content: Content
    @Binding var scrollOffset: CGPoint

    @State private var _uiScrollView: UIScrollView?
    // swiftlint:disable weak_delegate
    @StateObject private var scrollViewDelegate = MultiAppScrollViewDelegate()

    init(
        scrollOffset: Binding<CGPoint>,
        @ViewBuilder content: () -> Content
    ) {
        _scrollOffset = scrollOffset
        self.content = content()
    }

    var body: some View {
        content
            .findScrollView { scrollView in
                scrollView.delegate = scrollViewDelegate
                scrollViewDelegate.didScroll = { scrollView in
                    scrollOffset = CGPoint(
                        x: scrollView.contentOffset.x,
                        y: scrollView.contentOffset.y + scrollView.contentInset.top
                    )
                }
                self._uiScrollView = scrollView
            }
    }
}
