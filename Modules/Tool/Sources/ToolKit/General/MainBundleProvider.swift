// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MainBundleProvider {
    public static var mainBundle: Bundle = {
        var bundle = Bundle.main
        if bundle.bundleURL.pathExtension == "appex" {
            // If this is an App Extension (Today Extension), move up two directory levels
            // - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
            let url = bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
            if let otherBundle = Bundle(url: url) {
                bundle = otherBundle
            }
        }
        return bundle
    }()
}

extension Bundle {

    /// Provides the builder number and version using this format:
    /// - Production builds: v1.0.0 (1)
    /// - Internal builds: v1.0.0 (commit hash)
    /// - Returns: A `String` representing the build number
    public static func versionAndBuildNumber() -> String {
        let plist: InfoPlist = MainBundleProvider.mainBundle.plist
        let hash = plist.COMMIT_HASH as? String ?? ""
        var title = "v\(plist.version)"
        if BuildFlag.isInternal {
            title = "\(title) (\(hash))"
        } else {
            title = "\(title) (\(plist.build))"
        }
        return title
    }
}
