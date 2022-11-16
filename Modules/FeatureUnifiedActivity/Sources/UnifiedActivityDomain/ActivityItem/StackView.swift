// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ActivityItem {
    public struct StackView: Equatable, Decodable {
        public let leadingImage: ImageType?
        public let leading: [ItemType]
        public let trailing: [ItemType]
        public let trailingImage: ImageType?
    }
}
