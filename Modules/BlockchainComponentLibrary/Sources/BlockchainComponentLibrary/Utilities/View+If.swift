// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Helpers for conditionally applying modifiers
extension View {

    /// Conditionally apply modifiers to a given view
    ///
    /// See `ifLet` for version that takes an optional.
    ///
    /// - Parameters:
    ///   - condition: Condition returning true/false for execution of the following blocks
    ///   - then: If condition is true, apply modifiers here.
    ///   - else: If condition is false, apply modifiers here.
    /// - Returns: Self with modifiers applied accordingly.
    @ViewBuilder public func `if`(
        _ condition: @autoclosure () -> Bool,
        @ViewBuilder then: (Self) -> some View,
        @ViewBuilder else: (Self) -> some View
    ) -> some View {
        if condition() {
            then(self)
        } else {
            `else`(self)
        }
    }

    /// Conditionally apply modifiers to a given view
    ///
    /// See `ifLet` for version that takes an optional.
    ///
    /// - Parameters:
    ///   - condition: Condition returning true/false for execution of the following blocks
    ///   - then: If condition is true, apply modifiers here.
    /// - Returns: Self with modifiers applied, or unchanged self if condition was false
    @ViewBuilder public func `if`(
        _ condition: @autoclosure () -> Bool,
        @ViewBuilder then: (Self) -> some View
    ) -> some View {
        if condition() {
            then(self)
        } else {
            self
        }
    }

    /// Conditionally apply modifiers to a given view
    /// - Parameters:
    ///   - optional: Optional value to be ifLetped.
    ///   - then: Apply modifiers with ifLetped optional.
    ///   - else: Apply modifiers if optional is nil
    /// - Returns: Self with modifiers applied accordingly.
    @ViewBuilder public func ifLet<Value>(
        _ optional: Value?,
        @ViewBuilder then: (Self, Value) -> some View,
        @ViewBuilder else: (Self) -> some View
    ) -> some View {
        if let value = optional {
            then(self, value)
        } else {
            `else`(self)
        }
    }

    /// Conditionally apply modifiers to a given view
    /// - Parameters:
    ///   - optional: Optional value to be ifLetped.
    ///   - then: Apply modifiers with ifLetped optional.
    /// - Returns: Self with modifiers applied, or unchanged self if optional is nil
    @ViewBuilder public func ifLet<Value>(
        _ optional: Value?,
        @ViewBuilder then: (Self, Value) -> some View
    ) -> some View {
        if let value = optional {
            then(self, value)
        } else {
            self
        }
    }

    /// apply the closure to a given view, allows you to jump out of the current context
    /// and provide conditional modifiers like #if os(iOS) to decide what should be applied to the view
    /// - Parameters:
    ///   - then: call closure with self
    /// - Returns: Self with modifiers applied,
    @ViewBuilder public func apply(
        @ViewBuilder _ then: (Self) -> some View
    ) -> some View {
        then(self)
    }
}
