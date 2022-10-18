// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

extension Reactive where Base: UISwitch {
    public var thumbFillColor: Binder<UIColor?> {
        Binder(base) { switchView, color in
            guard let color else { return }
            switchView.thumbTintColor = color
        }
    }

    public var fillColor: Binder<UIColor> {
        Binder(base) { switchView, fillColor in
            switchView.onTintColor = fillColor
        }
    }

    public var isEnabled: Binder<Bool> {
        Binder(base) { switchView, isEnabled in
            switchView.isEnabled = isEnabled
        }
    }
}
