// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityItem {
    public struct Button: Equatable, Decodable {
        public let text: String
        public let buttonStyle: String
        public let actionType: String // "COPY"
        public let actionData: String
    }
}
