// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum ActivityState: String, Equatable, Decodable {
    case pending = "PENDING"
    case completed = "COMPLETED"
}

public struct ActivityEntry: Equatable, Decodable {
    public let id: String
    public let externalUrl: String
    public let item: ActivityItem.StackView
    public let state: ActivityState
    public let timestamp: TimeInterval
}
