// Copyright © Blockchain Luxembourg S.A. All rights reserved.

infix operator &&=: AssignmentPrecedence

public func &&= (x: inout Bool, y: Bool) {
    x = x && y
}

extension Bool {
    public var not: Bool { !self }
}
