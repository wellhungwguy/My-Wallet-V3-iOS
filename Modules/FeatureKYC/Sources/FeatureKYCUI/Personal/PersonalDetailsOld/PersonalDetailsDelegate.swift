// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

protocol PersonalDetailsDelegate: AnyObject {
    func onSubmission(_ input: KYCUpdatePersonalDetailsRequest, completion: @escaping () -> Void)
}
