// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol PermissionSettingsAPI: AnyObject {

    var didRequestCameraPermissions: Bool { get set }

    var didRequestMicrophonePermissions: Bool { get set }

    var didRequestNotificationPermissions: Bool { get set }
}
