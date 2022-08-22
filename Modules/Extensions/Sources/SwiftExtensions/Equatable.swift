// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public func isEqual(_ x: Any, _ y: Any) -> Bool {
    func f<LHS>(_ lhs: LHS) -> Bool {
        switch Existential<LHS>.self {
        case let p as AnyEquatable.Type:
            return p.isAnyEqual(x, y)
        case let c as AnyEquatableContainer.Type:
            return c.isAnyEqual(x, y)
        default:
            return false
        }
    }
    return _openExistential(x, do: f)
}

public protocol AnyEquatable {
    static func isAnyEqual(_ lhs: Any, _ rhs: Any) -> Bool
}

public protocol AnyEquatableContainer {
    static func isAnyEqual(_ lhs: Any, _ rhs: Any) -> Bool
}

private enum Existential<T> {}

extension Existential: AnyEquatable where T: Equatable {
    static func isAnyEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        guard let l = lhs as? T, let r = rhs as? T else { return false }
        return l == r
    }
}

extension Existential: AnyEquatableContainer where T: AnyEquatable {
    static func isAnyEqual(_ lhs: Any, _ rhs: Any) -> Bool { T.isAnyEqual(lhs, rhs) }
}

extension Dictionary: AnyEquatable {
    public static func isAnyEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        guard let l = lhs as? [Key: Any], let r = rhs as? [Key: Any] else { return false }
        return l.allSatisfy { k, v in
            r[k].map { isEqual($0, v) } ?? false
        }
    }
}

extension Array: AnyEquatable {
    public static func isAnyEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        guard let l = lhs as? [Element], let r = rhs as? [Element] else { return false }
        return Swift.zip(l, r).allSatisfy(isEqual)
    }
}

extension Optional: AnyEquatable {

    public static func isAnyEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        isEqual(recursiveFlatMapOptional(lhs) as Any, recursiveFlatMapOptional(rhs) as Any)
    }
}
