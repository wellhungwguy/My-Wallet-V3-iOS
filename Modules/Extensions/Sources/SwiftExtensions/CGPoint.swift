// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CoreGraphics

extension CGPoint {

    @inlinable public var array: [CGFloat] { [x, y] }
    @inlinable public var min: CGFloat { x < y ? x : y }
    @inlinable public var max: CGFloat { x > y ? x : y }
    @inlinable public var span: CGFloat { max - min }

    @inlinable public func magnitude() -> CGFloat { hypot(x, y) }
    @inlinable public func direction() -> CGFloat { atan2(y, x) }
    @inlinable public func angle(to other: Self) -> CGFloat { (other - self).direction() }
    @inlinable public func distance(to other: Self) -> CGFloat { (other - self).magnitude() }

    @inlinable public func angle(between point1: CGPoint, and point2: CGPoint) -> CGFloat {
        let a = distance(to: point1)
        let b = point1.distance(to: point2)
        let c = distance(to: point2)
        let d = 2 * a * c
        guard d != 0 else {
            return .zero
        }
        return acos(((a * a + c * c - b * b) / d).clamped(to: -1...1)) * (180 / CGFloat.pi)
    }
}

extension CGPoint {

    @inlinable public func point(at θ: CGFloat, distance: CGFloat) -> CGPoint {
        CGPoint(x: cos(θ), y: sin(θ)) * distance + self
    }
}

extension CGPoint {
    @inlinable public static func + (l: Self, r: CGFloat) -> Self { l.map { $0 + r } }
    @inlinable public static func - (l: Self, r: CGFloat) -> Self { l.map { $0 - r } }
    @inlinable public static func * (l: Self, r: CGFloat) -> Self { l.map { $0 * r } }
    @inlinable public static func / (l: Self, r: CGFloat) -> Self { l.map { $0 / r } }

    @inlinable public static func + (l: Self, r: CGSize) -> Self { self.init(x: l.x + r.width, y: l.y + r.height) }
    @inlinable public static func - (l: Self, r: CGSize) -> Self { self.init(x: l.x - r.width, y: l.y - r.height) }
    @inlinable public static func * (l: Self, r: CGSize) -> Self { self.init(x: l.x * r.width, y: l.y * r.height) }
    @inlinable public static func / (l: Self, r: CGSize) -> Self { self.init(x: l.x / r.width, y: l.y / r.height) }
}

extension CGPoint {
    @inlinable public static func += (l: inout Self, r: CGFloat) { l = l + r }
    @inlinable public static func -= (l: inout Self, r: CGFloat) { l = l - r }
    @inlinable public static func *= (l: inout Self, r: CGFloat) { l = l * r }
    @inlinable public static func /= (l: inout Self, r: CGFloat) { l = l / r }
}

extension CGPoint {
    @inlinable public static func + (l: Self, r: Self) -> Self { self.init(x: l.x + r.x, y: l.y + r.y) }
    @inlinable public static func - (l: Self, r: Self) -> Self { self.init(x: l.x - r.x, y: l.y - r.y) }
    @inlinable public static func * (l: Self, r: Self) -> Self { self.init(x: l.x * r.x, y: l.y * r.y) }
    @inlinable public static func / (l: Self, r: Self) -> Self { self.init(x: l.x / r.x, y: l.y / r.y) }
}

extension CGPoint {
    @inlinable public static func += (l: inout Self, r: Self) { l = l + r }
    @inlinable public static func -= (l: inout Self, r: Self) { l = l - r }
    @inlinable public static func *= (l: inout Self, r: Self) { l = l * r }
    @inlinable public static func /= (l: inout Self, r: Self) { l = l / r }
}

extension CGPoint {
    @inlinable public func map<T>(_ ƒ: (CGFloat) -> T) -> (T, T) { (ƒ(x), ƒ(y)) }
    @inlinable public func map(_ ƒ: (CGFloat) -> CGFloat) -> Self { Self(x: ƒ(x), y: ƒ(y)) }
}
