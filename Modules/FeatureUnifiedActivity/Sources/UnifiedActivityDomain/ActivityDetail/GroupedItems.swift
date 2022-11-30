// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityDetail {
    public struct GroupedItems: Equatable, Decodable {

        public struct Item: Equatable, Decodable {
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
