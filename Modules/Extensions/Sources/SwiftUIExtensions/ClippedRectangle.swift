// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CoreGraphics
import SwiftUI

public struct ClippedRectangle: Shape {

    public var x: CGFloat
    public var y: CGFloat

    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }

    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: rect.width * x, y: 0))
            path.addLine(to: CGPoint(x: rect.width * x, y: rect.height * y))
            path.addLine(to: CGPoint(x: 0, y: rect.height * y))
        }
    }
}
