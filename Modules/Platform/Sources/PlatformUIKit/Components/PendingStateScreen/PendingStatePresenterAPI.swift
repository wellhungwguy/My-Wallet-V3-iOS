// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import RxCocoa
import RxSwift

public protocol PendingStatePresenterAPI: AnyObject {
    var title: String { get }
    var error: Driver<UX.Error> { get }
    var viewModel: Driver<PendingStateViewModel> { get }
    var pendingStatusViewEdgeSize: CGFloat { get }
    var pendingStatusViewMainContainerViewRatio: CGFloat { get }
    var pendingStatusViewSideContainerRatio: CGFloat { get }
}

extension PendingStatePresenterAPI {
    public var title: String { "" }
    public var pendingStatusViewMainContainerViewRatio: CGFloat { 0.85 }
    public var pendingStatusViewSideContainerRatio: CGFloat { 0.35 }
    public var pendingStatusViewEdgeSize: CGFloat { 80 }
}
