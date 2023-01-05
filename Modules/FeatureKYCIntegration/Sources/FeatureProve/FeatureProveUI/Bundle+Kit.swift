// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let featureProveUI = Bundle.find(
        "FeatureKYCIntegration_FeatureProveUI.bundle",
        in: BundleFinder.self
    )
}
