// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum AsyncSequenceNextError: Error { case terminated(file: String, line: Int) }

extension AsyncSequence {

    public func next(file: String = #fileID, line: Int = #line) async throws -> Element {
        for try await o in self {
            return o
        }
        throw AsyncSequenceNextError.terminated(file: file, line: line)
    }
}
