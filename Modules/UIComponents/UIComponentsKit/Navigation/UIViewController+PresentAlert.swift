// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension UIViewController {
    public func presentAlert(_ alert: UIViewController) {
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.view.backgroundColor = .clear
        present(alert, animated: true)
    }

    public func dismissAlert() {
        presentedViewController?.view.isHidden = true
        dismiss(animated: true)
    }
}
