// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let featureSuperAppIntro = Bundle.find("FeatureSuperAppIntro_FeatureSuperAppIntroUI.bundle", in: BundleFinder.self)
}
