// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxDataSources
import RxSwift

public final class TermsViewCellModel {

    public var text: NSAttributedString?
    public let readMoreButtonTitle: String
    public let detailsDescription: String
    public var tapRelay: Signal<String> {
        tapPublishRelay
            .asSignal()
    }

    let tapPublishRelay = PublishRelay<String>()
    public init(
        text: NSAttributedString?,
        readMoreButtonTitle: String,
        detailsDescription: String
    ) {
        self.text = text
        self.readMoreButtonTitle = readMoreButtonTitle
        self.detailsDescription = detailsDescription
    }
}
