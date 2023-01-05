// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityDetail {
    public struct GroupedItems: Equatable, Codable {

        public struct Item: Equatable, Codable {
            public let title: String?
            public let itemGroup: [ItemType]
        }

        public let title: String?
        // public let subtitle: String? // Legacy
        public let icon: ImageType
        public let itemGroups: [Item]
        public let floatingActions: [ActivityItem.Button]
    }
}
