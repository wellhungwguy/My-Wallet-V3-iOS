// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import SwiftUI

/// Contains the interactive or static chrome
public struct MultiAppContainerChrome: View {
    /// The current total balance
    @State private var totalBalance: String = "$278,031.12"
    /// The current selected app mode
    @State private var currentModeSelection: AppMode = .trading
    /// The content offset for the modal sheet
    @State private var contentOffset: ModalSheetContext = .init(progress: 1.0, offset: .zero)
    /// The scroll offset for the inner scroll view, not currently used...
    @State private var scrollOffset: CGPoint = .zero
    /// `True` when a pull to refresh is triggered, otherwise `false`
    @State private var isRefreshing: Bool = false

    private var app: AppProtocol
    
    init(app: AppProtocol) {
        self.app = app
    }

    public var body: some View {
        if #available(iOS 16, *) {
            InteractiveMultiAppContent(
                totalBalance: $totalBalance,
                currentModeSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                scrollOffset: $scrollOffset,
                isRefreshing: $isRefreshing
            )
            .app(app)
        } else if #available(iOS 15, *) {
            StaticMultiAppContent(
                totalBalance: $totalBalance,
                currentModeSelection: $currentModeSelection,
                contentOffset: $contentOffset,
                scrollOffset: $scrollOffset,
                isRefreshing: $isRefreshing
            )
        } else {
            // when iOS 15.0+?, no refresable on <15.0
            EmptyView()
        }
    }
}

// temp for demo purposes.
func tempAsyncDelayMethod() async {
    try? await Task.sleep(nanoseconds: 2_000_000_000)
}

struct MultiAppChrome_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
