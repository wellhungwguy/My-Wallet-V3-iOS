// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import Localization
import ToolKit
import UIKit

extension ExternalAppOpener {

    public static var mailAppURLString: String {
        "message://"
    }

    public func openMailApp() {
        openMailApp(completionHandler: { _ in })
    }

    public func openMailApp(completionHandler: @escaping (Bool) -> Void) {
        guard let url = URL(string: UIApplication.mailAppURLString) else {
            completionHandler(false)
            return
        }
        open(url, completionHandler: completionHandler)
    }

    public func openSettingsApp() {
        openSettingsApp(completionHandler: { _ in })
    }

    public func openSettingsApp(completionHandler: @escaping (Bool) -> Void) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            completionHandler(false)
            return
        }
        open(url, completionHandler: completionHandler)
    }
}

extension UIApplication: ExternalAppOpener {

    public func open(_ url: URL, completionHandler: @escaping (Bool) -> Void) {
        guard canOpenURL(url) else {
            completionHandler(false)
            return
        }
        open(url, options: [.universalLinksOnly: false], completionHandler: completionHandler)
    }
}

extension UIApplication {

    /// Opens the mail application, if possible, otherwise, displays an error
    public func openMailApplication() {
        openMailApp { success in
            guard success else {
                let message = String(
                    format: LocalizationConstants.Errors.cannotOpenURLArg, UIApplication.mailAppURLString
                )
                let alertPresenter: AlertViewPresenterAPI = DIKit.resolve()
                alertPresenter.standardError(message: message)
                return
            }
        }
    }
}
