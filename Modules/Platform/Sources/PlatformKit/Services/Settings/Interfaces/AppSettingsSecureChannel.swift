// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public protocol AppSettingsSecureChannel: AnyObject {
    var deviceKey: String? { get set }
    var browserIdentities: String? { get set }
}

extension AppSettingsSecureChannel {
    public var deviceKey: Single<String?> {
        Single.deferred { [weak self] in
            guard let self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.deviceKey)
        }
    }

    public var browserIdentities: Single<String?> {
        Single.deferred { [weak self] in
            guard let self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.browserIdentities)
        }
    }
}
