// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import os

@usableFromInline let logger = Logger(subsystem: "com.blockchain.peek", category: "🔎")

extension CustomStringConvertible {

    @inlinable
    @discardableResult
    public func peek(
        as level: OSLogType = .debug,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        if let condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(self) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek(
        as level: OSLogType = .debug,
        _ message: @escaping @autoclosure () -> some CustomStringConvertible,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        if let condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(message()) \(self) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek(
        as level: OSLogType = .debug,
        _ keyPath: KeyPath<Self, some CustomStringConvertible>,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        if let condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(self[keyPath: keyPath]) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek(
        as level: OSLogType = .debug,
        _ message: @escaping @autoclosure () -> some CustomStringConvertible,
        _ keyPath: KeyPath<Self, some CustomStringConvertible>,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        if let condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(message()) \(self[keyPath: keyPath]) \(CodeLocation(function, file, line))")
        return self
    }
}

extension Optional {

    @inlinable
    @discardableResult
    public func peek(
        as level: OSLogType = .debug,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        if let condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(self) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek(
        as level: OSLogType = .debug,
        _ message: @escaping @autoclosure () -> some CustomStringConvertible,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        if let condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(message()) \(String(describing: self)) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek(
        as level: OSLogType = .debug,
        _ keyPath: KeyPath<Self, some CustomStringConvertible>,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        if let condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(self[keyPath: keyPath]) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek(
        as level: OSLogType = .debug,
        _ message: @escaping @autoclosure () -> some CustomStringConvertible,
        _ keyPath: KeyPath<Self, some CustomStringConvertible>,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        if let condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(message()) \(self[keyPath: keyPath]) \(CodeLocation(function, file, line))")
        return self
    }
}
