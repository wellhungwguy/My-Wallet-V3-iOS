// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public protocol KYCSettingsAPI: AnyObject {

    var didTapOnDocumentResubmissionDeepLink: Bool { get set }

    var documentResubmissionLinkReason: String? { get set }

    var didTapOnKycDeepLink: Bool { get set }

    var isCompletingKyc: Bool { get set }

    var latestKycPage: KYCPageType? { get set }

    func reset()
}

extension KYCSettingsAPI {
    public var isCompletingKyc: Single<Bool> {
        Single.deferred { [weak self] in
            guard let self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.isCompletingKyc)
        }
    }
}
