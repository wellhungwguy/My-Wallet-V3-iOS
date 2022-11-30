// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

@available(iOS 16.0, *)
enum AppChromeDetents {
    case collapsed
    case semiCollapsed
    case expanded

    var identifier: String {
        switch self {
        case .collapsed:
            return "Custom:\(CollapsedDetent.self)"
        case .semiCollapsed:
            return "Custom:\(SemiCollapsedDetent.self)"
        case .expanded:
            return "Custom:\(ExpandedDetent.self)"
        }
    }

    var detent: PresentationDetent {
        switch self {
        case .collapsed:
            return .collapsed
        case .semiCollapsed:
            return .semiCollapsed
        case .expanded:
            return .expanded
        }
    }

    static var supportedDetents: [AppChromeDetents] = [
        AppChromeDetents.collapsed,
        AppChromeDetents.semiCollapsed,
        AppChromeDetents.expanded
    ]
}

@available(iOS 16.0, *)
extension PresentationDetent {
    static let collapsed = Self.custom(CollapsedDetent.self)
    static let semiCollapsed = Self.custom(SemiCollapsedDetent.self)
    static let expanded = Self.custom(ExpandedDetent.self)
}

@available(iOS 16.0, *)
protocol FractionCustomPresentationDetent: CustomPresentationDetent {
    static var fraction: CGFloat { get }
}

@available(iOS 16.0, *)
struct CollapsedDetent: FractionCustomPresentationDetent {
    static let fraction: CGFloat = 0.9

    static func height(in context: Context) -> CGFloat? {
        // this fixed fraction is really not that great
        // quite tricky to pass in an updated fraction based on the header height...
        context.maxDetentValue * fraction
    }
}

@available(iOS 16.0, *)
struct SemiCollapsedDetent: FractionCustomPresentationDetent {
    static let fraction: CGFloat = 0.95

    static func height(in context: Context) -> CGFloat? {
        // this fixed fraction is really not that great
        // quite tricky to pass in an updated fraction based on the header height...
        context.maxDetentValue * fraction
    }
}

@available(iOS 16.0, *)
struct ExpandedDetent: FractionCustomPresentationDetent {
    static let fraction: CGFloat = 0.9999
    static func height(in context: Context) -> CGFloat? {
        context.maxDetentValue * fraction
    }
}
