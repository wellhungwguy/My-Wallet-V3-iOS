// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import UIKit

/// Protocol definition for a view that contains a CTA button at the bottom of it's view.
/// Conforming to this protocol will auto-adjust the CTA button whenever the keyboard
/// is presented/hidden.
public protocol BottomButtonContainerView {

    /// This is to be set equal to the original bottom constraint
    /// set on the view pinning it to the bottom of it's parent.
    var originalBottomButtonConstraint: CGFloat! { get set }

    /// Some screens may want to alter the offset of the
    /// view. This is normally set to `0` but can be set to
    /// any other value and it will be added to the keyboard's
    /// height.
    var optionalOffset: CGFloat { get set }

    var layoutConstraintBottomButton: NSLayoutConstraint! { get }
}

extension BottomButtonContainerView where Self: UIViewController {

    /// Sets up this view so that it can respond to keyboard show/hide events.
    /// This should be called in viewDidAppear()
    public func setUpBottomButtonContainerView() {
        NotificationCenter.when(UIResponder.keyboardWillShowNotification) {
            self.keyboardWillShow(with: KeyboardObserver.Payload(with: $0.userInfo))
        }
        NotificationCenter.when(UIResponder.keyboardWillHideNotification) {
            self.keyboardWillHide(with: KeyboardObserver.Payload(with: $0.userInfo))
        }
    }

    /// Call this in deinit to remove the instance as an observer to the NotificationCenter
    public func cleanUp() {
        NotificationCenter.default.removeObserver(self)
    }

    public func keyboardWillShow(with payload: KeyboardObserver.Payload?) {
        guard let payload = payload else { return }
        UIView.animate(
            withDuration: payload.duration,
            delay: 0,
            options: payload.curve.animationOption,
            animations: { [self] in
                layoutConstraintBottomButton.constant = originalBottomButtonConstraint + payload.end.height + optionalOffset
                view.layoutIfNeeded()
            },
            completion: nil
        )
    }

    public func keyboardWillHide(with payload: KeyboardObserver.Payload?) {
        guard let payload = payload else { return }
        UIView.animate(
            withDuration: payload.duration,
            delay: 0,
            options: payload.curve.animationOption,
            animations: { [self] in
                layoutConstraintBottomButton.constant = originalBottomButtonConstraint
                view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}
