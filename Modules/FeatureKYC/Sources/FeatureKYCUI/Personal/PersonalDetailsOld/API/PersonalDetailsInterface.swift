// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit

protocol PersonalDetailsInterface: AnyObject {
    func primaryButtonActivityIndicator(_ visibility: Visibility)
    func primaryButtonEnabled(_ enabled: Bool)
    func populatePersonalDetailFields(_ details: PersonalDetails)
}
