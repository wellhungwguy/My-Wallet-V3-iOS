// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import PlatformUIKit
import UIKit

private typealias L10n = LocalizationConstants.NewKYC.Steps.AccountUsage

enum NavigationCTA {
    case dismiss
    case help
    case skip
    case none
}

extension NavigationCTA {
    var image: UIImage? {
        switch self {
        case .dismiss:
            return UIImage(
                named: "Close Circle v2",
                in: .componentLibrary,
                compatibleWith: nil
            )?.withRenderingMode(.alwaysOriginal)
        case .help:
            return UIImage(named: "ios_icon_more", in: .featureKYCUI, compatibleWith: nil)
        case .none, .skip:
            return nil
        }
    }

    var title: String {
        switch self {
        case .dismiss, .help, .none:
            return ""
        case .skip:
            return L10n.skipButtonTitle
        }
    }

    var visibility: PlatformUIKit.Visibility {
        switch self {
        case .dismiss, .help, .skip:
            return .visible
        case .none:
            return .hidden
        }
    }
}
