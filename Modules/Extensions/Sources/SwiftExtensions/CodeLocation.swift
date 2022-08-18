// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct CodeLocation: Codable, Hashable, CustomDebugStringConvertible, CustomStringConvertible {

    var function: String
    var file: String
    var line: Int

    public init(
        _ function: String = #function,
        _ file: String = #filePath,
        _ line: Int = #line
    ) {
        self.function = function
        self.file = file
        self.line = line
    }

    public var debugDescription: String {
        "← \(function)\t\(file)\t\(line)"
    }

    public var description: String {
        var __ = file
        if let i = __.lastIndex(of: "/") {
            __ = __.suffix(from: __.index(after: i)).description
        }
        return "← \(function)\t\(__):\(line)"
    }
}
