// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class FooterTableViewCellPresenter {

    public var identifier: String {
        content.text
    }

    public let content: LabelContent

    public init(
        text: String,
        accessibility: Accessibility
    ) {
        self.content = .init(
            text: text,
            font: .main(.medium, 14.0),
            color: .descriptionText,
            alignment: .center,
            accessibility: accessibility
        )
    }
}
