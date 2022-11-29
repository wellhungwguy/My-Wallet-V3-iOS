// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityItem {
    public struct Button: Equatable, Codable {
        public let text: String
        public let buttonStyle: String
        public let actionType: String
        public let actionData: String
    }
}
