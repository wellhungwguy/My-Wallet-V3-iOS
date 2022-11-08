// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxDataSources
import RxSwift

public final class LabelInfoViewCellModel {

    public var title: String?
    public let subtitle: String?
    public var isInfoButtonVisible: Bool
    public var tapInfoRelay: Signal<Void> {
        tapInfoPublishRelay
            .asSignal()
    }
    let tapInfoPublishRelay = PublishRelay<Void>()
    public init(
        title: String?,
        subtitle: String?,
        isInfoButtonVisible: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isInfoButtonVisible = isInfoButtonVisible
    }
}
