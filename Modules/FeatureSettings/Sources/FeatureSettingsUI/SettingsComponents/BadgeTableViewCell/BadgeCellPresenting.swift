// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

/// This is used on `BadgeTableViewCell`. There are many
/// types of `BadgeTableViewCell` (e.g. PIT connection status, KYC status, mobile
/// verification status, etc). Each of these cells need their own implementation of
/// `LabelContentPresenting` and `BadgeAssetPresenting`
protocol BadgeCellPresenting: AsyncPresenting {
    var accessibility: Accessibility { get }
    var labelContentPresenting: LabelContentPresenting { get }
    var badgeAssetPresenting: BadgeAssetPresenting { get }
}

extension BadgeCellPresenting {
    var accessibility: Accessibility {
        .none
    }
}
