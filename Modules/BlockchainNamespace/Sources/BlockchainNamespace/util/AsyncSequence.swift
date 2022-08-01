// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum AsyncSequenceNextError: Error { case terminated }

extension AsyncSequence {

    @discardableResult
    public func next() async throws -> Element {
        for try await o in self {
            return o
        }
        throw AsyncSequenceNextError.terminated
    }
}
