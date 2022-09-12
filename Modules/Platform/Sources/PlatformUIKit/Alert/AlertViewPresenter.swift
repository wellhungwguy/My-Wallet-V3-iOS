// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import ToolKit
import UIComponentsKit

final class AlertViewPresenter: AlertViewPresenterAPI {

    // MARK: - Private Properties

    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let loadingViewPresenter: LoadingViewPresenting

    // MARK: - Setup

    init(
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve()
    ) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.loadingViewPresenter = loadingViewPresenter
    }

    // MARK: AlertViewPresenterAPI

    func notify(content: AlertViewContent, in viewController: UIViewController?) {
        standardNotify(
            title: content.title,
            message: content.message,
            actions: content.actions,
            in: viewController
        )
    }

    func error(
        in viewController: UIViewController? = nil,
        message: String? = nil,
        action: (() -> Void)? = nil
    ) {
        typealias AlertString = LocalizationConstants.ErrorAlert
        standardNotify(
            title: AlertString.title,
            message: message ?? AlertString.message,
            actions: [
                UIAlertAction(
                    title: AlertString.button,
                    style: .default,
                    handler: { _ in
                        action?()
                    }
                )
            ],
            in: viewController
        )
    }

    func standardError(message: String, in viewController: UIViewController?) {
        standardNotify(
            title: LocalizationConstants.Errors.error,
            message: message,
            in: viewController,
            handler: nil
        )
    }

    // MARK: Private Methods

    private func standardNotify(
        title: String,
        message: String,
        in viewController: UIViewController? = nil,
        handler: AlertViewContent.Action? = nil
    ) {
        runOnMainThread {
            let standardAction = UIAlertAction(
                title: LocalizationConstants.okString,
                style: .cancel,
                handler: handler
            )
            self.standardNotify(
                title: title,
                message: message,
                actions: [standardAction],
                in: viewController
            )
        }
    }

    /// Allows custom actions to be included in the standard alert presentation
    private func standardNotify(
        title: String,
        message: String,
        actions: [UIAlertAction],
        in viewController: UIViewController? = nil
    ) {
        runOnMainThread { [topMostViewControllerProvider] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            actions.forEach { alert.addAction($0) }
            if actions.isEmpty {
                alert.addAction(UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil))
            }

            guard let presentingVC = viewController ?? topMostViewControllerProvider.topMostViewController else {
                return
            }

            guard let previousAlertController = presentingVC.presentedViewController as? UIAlertController else {
                presentingVC.present(alert, animated: true, completion: nil)
                return
            }
            previousAlertController.dismiss(animated: false) {
                presentingVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}

private func runOnMainThread(_ action: @escaping () -> Void) {
    if Thread.isMainThread {
        action()
    } else {
        DispatchQueue.main.async(execute: action)
    }
}
