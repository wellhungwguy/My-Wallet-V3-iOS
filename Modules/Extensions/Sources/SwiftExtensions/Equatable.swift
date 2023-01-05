// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public func isEqual(_ x: Any, _ y: Any) -> Bool {
    (x as? any Equatable)?.isEqual(to: y) ?? false
}

extension Equatable {

    fileprivate func isEqual(to other: Any) -> Bool {
        self == other as? Self
    }
}
