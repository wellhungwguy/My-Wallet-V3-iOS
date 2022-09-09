// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import struct CoreGraphics.CGFloat

extension BinaryInteger {
    @inlinable public var i: Int { .init(self) }
    @inlinable public var d: Double { .init(self) }
    @inlinable public var f: Float { .init(self) }
    @inlinable public var cg: CGFloat { .init(self) }
}

extension BinaryFloatingPoint {
    @inlinable public var i: Int { .init(self) }
    @inlinable public var d: Double { .init(self) }
    @inlinable public var f: Float { .init(self) }
    @inlinable public var cg: CGFloat { .init(self) }
}
