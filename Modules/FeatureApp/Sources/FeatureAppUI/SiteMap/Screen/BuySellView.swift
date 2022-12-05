//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import SwiftUI

public struct BuySellView: UIViewControllerRepresentable {

    @Binding public var selectedSegment: Int

    public init(selectedSegment: Binding<Int>) {
        self._selectedSegment = selectedSegment
    }

    public func updateUIViewController(_ uiViewController: SegmentedViewController, context: Context) {
        uiViewController.selectSegment(selectedSegment)
    }

    public func makeUIViewController(context: Context) -> SegmentedViewController {
        let viewController = SegmentedViewController(
            presenter: DIKit.resolve(),
            selectedSegmentBinding: $selectedSegment
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
