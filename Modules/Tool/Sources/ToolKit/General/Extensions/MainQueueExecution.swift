// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Container for executions
public enum Execution {

    /// Main queue execution
    public enum MainQueue {

        /// A work item to be executed
        public typealias WorkItem = () -> Void

        /// Executes a given action on the main queue efficiently firstly
        /// by making sure the current queue is the main one
        public static func dispatch(_ action: @escaping WorkItem) {
            if Thread.isMainThread {
                action()
            } else {
                DispatchQueue.main.async(execute: action)
            }
        }

        /// Executes a given action on the main queue efficiently first
        /// by making sure the current queue is the main one. If not - executes
        /// synchronically
        public static func dispatchSync(_ action: @escaping WorkItem) {
            if Thread.isMainThread {
                action()
            } else {
                DispatchQueue.main.sync(execute: action)
            }
        }
    }
}
