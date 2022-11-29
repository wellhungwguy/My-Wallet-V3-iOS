/// Extracted from Introspect library
/// https://github.com/siteline/SwiftUI-Introspect

import SwiftUI

extension View {
    @ViewBuilder
    func inject(_ view: some View) -> some View {
        overlay(view.frame(width: 0, height: 0))
    }
}

// MARK: View Finding

enum Introspect {
    static func findViewHost(_ view: UIView) -> UIView? {
        var superview = view.superview
        while let s = superview {
            if NSStringFromClass(type(of: s)).contains("ViewHost") {
                return s
            }
            superview = s.superview
        }
        return nil
    }

    public static func previousSibling<AnyViewType: UIView>(
        containing type: AnyViewType.Type,
        from entry: UIView
    ) -> AnyViewType? {

        guard let superview = entry.superview,
            let entryIndex = superview.subviews.firstIndex(of: entry),
            entryIndex > 0
        else {
            return nil
        }

        for subview in superview.subviews[0..<entryIndex].reversed() {
            if let typed = findChild(ofType: type, in: subview) {
                return typed
            }
        }

        return nil
    }

    public static func findChild<AnyViewType: UIView>(
        ofType type: AnyViewType.Type,
        in root: UIView
    ) -> AnyViewType? {
        for subview in root.subviews {
            if let typed = subview as? AnyViewType {
                return typed
            } else if let typed = findChild(ofType: type, in: subview) {
                return typed
            }
        }
        return nil
    }
}
