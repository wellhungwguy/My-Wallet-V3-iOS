// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Foundation

public struct Referral: Equatable, Hashable, Decodable {

    public var code: String
    public var rewardTitle: String
    public var rewardSubtitle: String
    public var criteria: [Step]
    public var promotion: UX.Dialog?
    public var announcement: UX.Dialog?

    public init(
        code: String,
        rewardTitle: String,
        rewardSubtitle: String,
        criteria: [Step],
        promotion: UX.Dialog?,
        announcement: UX.Dialog?
    ) {
        self.code = code
        self.rewardTitle = rewardTitle
        self.rewardSubtitle = rewardSubtitle
        self.criteria = criteria
        self.promotion = promotion
        self.announcement = announcement
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
        self.text = try container.decode(String.self)
    }
}
