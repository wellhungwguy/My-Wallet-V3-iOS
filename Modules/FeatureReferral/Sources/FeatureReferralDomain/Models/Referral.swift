// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Foundation

public struct Referral: Equatable, Hashable, Decodable {

    public var code: String
    public var rewardTitle: String
    public var rewardSubtitle: String
    public var criteria: [Step]

    public var style: UX.Style?
    public var icon: UX.Icon?

    public init(
        code: String,
        rewardTitle: String,
        rewardSubtitle: String,
        criteria: [Step],
        style: UX.Style?,
        icon: UX.Icon?
    ) {
        self.code = code
        self.rewardTitle = rewardTitle
        self.rewardSubtitle = rewardSubtitle
        self.criteria = criteria
        self.style = style
        self.icon = icon
    }
}

public struct Step: Identifiable, Equatable, Hashable, Decodable {

    public var id = UUID()
    public let text: String

    public init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        text = try container.decode(String.self)
    }
}
