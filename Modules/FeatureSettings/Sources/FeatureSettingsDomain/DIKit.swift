// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformKit
import ToolKit

extension DependencyContainer {

    public static var featureSettingsDomain = module {

        factory { PITConnectionStatusProvider() as PITConnectionStatusProviding }

        factory { TierLimitsProvider() as TierLimitsProviding }

        factory { () -> RecoveryPhraseStatusProviding in
            RecoveryPhraseStatusProvider(mnemonicVerificationStatusProvider: DIKit.resolve())
        }
    }
}
