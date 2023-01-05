// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum AsyncSequenceNextError: Error, LocalizedError {
    case terminated(file: String, line: Int)
}

extension AsyncSequenceNextError {

    public var errorDescription: String? {
        switch self {
        case .terminated(let file, let line):
            return "Terminated without returning an value. \(file):\(line)"
        }
    }
}

extension AsyncSequence {

    public func next(file: String = #fileID, line: Int = #line) async throws -> Element {
        for try await o in self {
            return o
        }
        throw AsyncSequenceNextError.terminated(file: file, line: line)
    }
}
