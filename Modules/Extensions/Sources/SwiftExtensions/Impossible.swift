// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Unconditionally prints an unimplemented message and stops execution.
/// This is useful when and API is only partially implemented.
///
/// - Parameters:
///   - file: The file name to print with `message`. The default is the file
///     where `unimplemented(file:line:)` is called.
///   - line: The line number to print along with `message`. The default is the
///     line number where `unimplemented(file:line:)` is called.
public func unimplemented(_ message: String = "", file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Not implemented. \(message)", file: file, line: line)
}

/// Unconditionally prints an impossible state message and stops execution.
/// This is useful when and API is only partially implemented.
///
/// - Parameters:
///   - file: The file name to print with `message`. The default is the file
///     where `unimplemented(file:line:)` is called.
///   - line: The line number to print along with `message`. The default is the
///     line number where `unimplemented(file:line:)` is called.
public func impossible(_ message: String = "", file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Impossible state. \(message)", file: file, line: line)
}

/// Terminates the app with a `fatalError` marking an unexpected deallocation at the caller's file and line
public func unexpectedDeallocation(file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("Unexpected deallocation at \(#file):\(#line)")
}
