// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AccountPickerSimpleHeaderModel: Equatable {

    var height: CGFloat {
        searchable ? 104 : 64
    }

    public let subtitle: String
    public let searchable: Bool

    var subtitleLabel: LabelContent {
        LabelContent(
            text: subtitle,
            font: .main(.medium, 14),
            color: .descriptionText
        )
    }

    public init(
        subtitle: String,
        searchable: Bool = false
    ) {
        self.subtitle = subtitle
        self.searchable = searchable
    }
}
