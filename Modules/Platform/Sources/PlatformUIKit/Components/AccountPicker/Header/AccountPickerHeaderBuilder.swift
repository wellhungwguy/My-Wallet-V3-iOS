// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public protocol AccountPickerHeaderViewAPI: UIView {
    var searchBar: UISearchBar? { get }
}

public struct AccountPickerHeaderBuilder {

    private let headerType: AccountPickerHeaderType

    public init(headerType: AccountPickerHeaderType) {
        self.headerType = headerType
    }

    var isAlwaysVisible: Bool {
        switch headerType {
        case .none:
            return false
        case .simple(let model):
            return model.searchable
        case .default(let model):
            return model.searchable
        }
    }

    public var defaultHeight: CGFloat {
        switch headerType {
        case .none:
            return 0
        case .default(let model):
            return model.height
        case .simple(let model):
            return model.height
        }
    }

    public func headerView(fittingWidth width: CGFloat, customHeight: CGFloat?) -> AccountPickerHeaderViewAPI? {
        let height = customHeight ?? defaultHeight
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        switch headerType {
        case .none:
            return nil
        case .default(let model):
            let view = AccountPickerHeaderView(frame: frame)
            view.model = model
            return view
        case .simple(let model):
            let view = AccountPickerSimpleHeaderView(frame: frame)
            view.model = model
            return view
        }
    }
}

extension AccountPickerHeaderBuilder: HeaderBuilder {
    public func view(fittingWidth width: CGFloat, customHeight: CGFloat?) -> UIView? {
        headerView(fittingWidth: width, customHeight: customHeight)
    }
}
