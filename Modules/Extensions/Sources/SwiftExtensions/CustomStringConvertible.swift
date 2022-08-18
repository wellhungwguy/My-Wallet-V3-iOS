// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import os

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
        os_log(level, "$@ ← %@:%@ %@", description, file, line, function)
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
        os_log(level, "%@ $@ ← %@:%@ %@", message().description, description, file, line, function)
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
        os_log(level, "$@ ← %@:%@ %@", self[keyPath: keyPath].description, file, line, function)
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
        os_log(level, "$@ $@ ← %@:%@ %@", message().description, self[keyPath: keyPath].description, file, line, function)
        return self
    }
}
