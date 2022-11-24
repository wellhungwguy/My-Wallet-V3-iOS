// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityItem {
    public struct Text: Equatable, Codable {
        public struct Style: Equatable, Codable {
            public let style: String
            public let color: String
        }

        public let value: String
        public let style: Style
    }
}
