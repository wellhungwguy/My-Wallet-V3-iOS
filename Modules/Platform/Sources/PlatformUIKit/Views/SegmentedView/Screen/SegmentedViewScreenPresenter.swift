// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol SegmentedViewScreenViewController where Self: UIViewController {
    func adjustInsetForBottomButton(withHeight height: CGFloat)
}

public struct SegmentedViewScreenItem {
    let title: String
    let id: AnyHashable
    let viewController: SegmentedViewScreenViewController

    public init(
        title: String,
        id: some Hashable,
        viewController: SegmentedViewScreenViewController
    ) {
        self.title = title
        self.id = id
        self.viewController = viewController
    }
}

public enum SegmentedViewScreenLocation {
    /// SegmentedView will be on top of view, and the given `Screen.Style.TitleView` will be set to the navigation bar.
    case top(Screen.Style.TitleView)
    /// SegmentedView will be on navigation bar.
    case navBar
}

public protocol SegmentedViewScreenPresenting: AnyObject {

    // MARK: - Navigation Properties

    var leadingButton: Screen.Style.LeadingButton { get }
    var leadingButtonTapRelay: PublishRelay<Void> { get }

    var trailingButton: Screen.Style.TrailingButton { get }
    var trailingButtonTapRelay: PublishRelay<Void> { get }

    var barStyle: Screen.Style.Bar { get }
    var segmentedViewLocation: SegmentedViewScreenLocation { get }

    // MARK: - Segmented View

    var segmentedViewModel: SegmentedViewModel { get }
    var items: [SegmentedViewScreenItem] { get }

    // MARK: - Segmented View Selection

    var itemIndexSelected: Observable<(index: Int, animated: Bool)> { get }
    var itemIndexSelectedRelay: BehaviorRelay<(index: Int, animated: Bool)> { get }
}

extension SegmentedViewScreenPresenting {
    public func createSegmentedViewModelItems() -> [SegmentedViewModel.Item] {
        items
            .enumerated()
            .map { index, item in
                SegmentedViewModel.Item(
                    content: .title(item.title),
                    id: item.id,
                    action: { [weak self] in
                        self?.itemIndexSelectedRelay.accept((index: index, animated: true))
                    }
                )
            }
    }

    public var itemIndexSelected: Observable<(index: Int, animated: Bool)> {
        itemIndexSelectedRelay
            .asObservable()
    }
}
