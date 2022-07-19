infix operator &&=: AssignmentPrecedence

public func &&= (x: inout Bool, y: Bool) {
    x = x && y
}
