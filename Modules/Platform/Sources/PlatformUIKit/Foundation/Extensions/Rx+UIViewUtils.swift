// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

/// Extension for rx that makes `UIProgressView` properties reactive
extension Reactive where Base: UIProgressView {
    public var progress: Binder<Float> {
        Binder(base) { view, progress in
            view.setProgress(progress, animated: true)
        }
    }

    public var trackTintColor: Binder<UIColor> {
        Binder(base) { view, color in
            view.trackTintColor = color
        }
    }

    public var fillColor: Binder<UIColor> {
        Binder(base) { view, color in
            view.progressTintColor = color
        }
    }
}

extension Reactive where Base: UIView {
    public var rx_heightAnchor: Binder<CGFloat> {
        Binder(base) { view, height in
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension Reactive where Base: UILabel {
    public var textColor: Binder<UIColor> {
        Binder(base) { label, color in
            label.textColor = color
        }
    }
}

extension Reactive where Base: UIImageView {
    /// If this value is `nil`, the image derives its `tintColor`
    /// from its superview.
    public var tintColor: Binder<UIColor?> {
        Binder(base) { imageView, color in
            guard let tintColor = color else { return }
            imageView.tintColor = tintColor
        }
    }
}
