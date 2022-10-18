// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

private class BundleFinder {}
extension Bundle {
    public static let featureBackupRecoveryPhrase = Bundle.find("FeatureBackupRecoveryPhrase_FeatureBackupRecoveryPhraseUI.bundle", in: BundleFinder.self)
}
