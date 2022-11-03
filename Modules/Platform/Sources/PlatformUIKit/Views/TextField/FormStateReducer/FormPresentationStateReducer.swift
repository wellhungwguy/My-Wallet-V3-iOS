// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class FormPresentationStateReducer {

    // MARK: - Types

    public enum ReducingError: Error {

        /// Imput sent to reducer is an empty collection
        case forbiddenEmptyInput

        /// Unexpectedly, could not reduce the input into `FormPresentationState`
        case unreduceableInput
    }

    // MARK: - Setup

    public init() {}

    // MARK: - API

    public func reduce(states: [TextFieldViewModel.State]) throws -> FormPresentationState {
        guard !states.isEmpty else { throw ReducingError.forbiddenEmptyInput }
        let isValid = states
            .map { $0.isValid || $0.isCautioning }
            .areAllElements(equal: true)
        if states.count > 1, isValid {
            return .valid
        }
        if states.contains(.empty) {
            return .invalid(.emptyTextField)
        }
        if (states.contains { $0.isInvalid }) {
            return .invalid(.invalidTextField)
        }
        if (states.contains { $0.isMismatch }) {
            return .invalid(.invalidTextField)
        }
        return .valid
    }
}

extension Array where Element: Equatable {
    public var areAllElementsEqual: Bool {
        guard let first else { return true }
        return !dropFirst().contains { $0 != first }
    }

    /// Returns `true` if if all elements are equal to a given value
    public func areAllElements(equal element: Element) -> Bool {
        !contains { $0 != element }
    }
}
