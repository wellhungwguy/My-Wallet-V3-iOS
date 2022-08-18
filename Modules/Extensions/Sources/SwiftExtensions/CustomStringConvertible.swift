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
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(self) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek<Message>(
        as level: OSLogType = .debug,
        _ message: @escaping @autoclosure () -> Message,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self where Message: CustomStringConvertible {
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(message()) \(self) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek<Property>(
        as level: OSLogType = .debug,
        _ keyPath: KeyPath<Self, Property>,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self where Property: CustomStringConvertible {
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(self[keyPath: keyPath]) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek<Message, Property>(
        as level: OSLogType = .debug,
        _ message: @escaping @autoclosure () -> Message,
        _ keyPath: KeyPath<Self, Property>,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self where Message: CustomStringConvertible, Property: CustomStringConvertible {
        if let condition = condition, self[keyPath: condition] == false { return self }
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
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(self) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek<Message>(
        as level: OSLogType = .debug,
        _ message: @escaping @autoclosure () -> Message,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self where Message: CustomStringConvertible {
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(message()) \(String(describing: self)) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek<Property>(
        as level: OSLogType = .debug,
        _ keyPath: KeyPath<Self, Property>,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self where Property: CustomStringConvertible {
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(self[keyPath: keyPath]) \(CodeLocation(function, file, line))")
        return self
    }

    @inlinable
    @discardableResult
    public func peek<Message, Property>(
        as level: OSLogType = .debug,
        _ message: @escaping @autoclosure () -> Message,
        _ keyPath: KeyPath<Self, Property>,
        if condition: KeyPath<Self, Bool>? = nil,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self where Message: CustomStringConvertible, Property: CustomStringConvertible {
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log(level: level, "\(message()) \(self[keyPath: keyPath]) \(CodeLocation(function, file, line))")
        return self
    }
}
