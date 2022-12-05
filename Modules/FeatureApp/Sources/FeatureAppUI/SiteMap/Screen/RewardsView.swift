//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestUI
import SwiftUI

public struct RewardsView: UIViewControllerRepresentable {

    public init() {}

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    public func makeUIViewController(context: Context) -> some UIViewController {
        InterestAccountListHostingController(embeddedInNavigationView: false)
    }
}
