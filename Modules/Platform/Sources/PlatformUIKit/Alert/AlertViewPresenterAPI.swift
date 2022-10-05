// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol AlertViewPresenterAPI: AnyObject {
    func notify(content: AlertViewContent, in viewController: UIViewController?)
    func error(in viewController: UIViewController?, message: String?, action: (() -> Void)?)
    func standardError(message: String, in viewController: UIViewController?)
}

extension AlertViewPresenterAPI {
    public func notify(content: AlertViewContent) {
        notify(content: content, in: nil)
    }

    public func error(in viewController: UIViewController?, action: (() -> Void)?) {
        error(in: viewController, message: nil, action: action)
    }

    public func standardError(message: String) {
        standardError(message: message, in: nil)
    }
}
