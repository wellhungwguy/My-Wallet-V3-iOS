// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import RxSwift
import ToolKit
import UIComponentsKit

@objc
public final class AlertViewPresenter: NSObject, AlertViewPresenterAPI {

    @Inject @objc public static var shared: AlertViewPresenter

    public let disposeBag = DisposeBag()

    // MARK: - Services

    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let loadingViewPresenter: LoadingViewPresenting

    // MARK: - Setup

    init(
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve()
    ) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.loadingViewPresenter = loadingViewPresenter
        super.init()
    }

    @objc
    public func standardNotify(
        title: String,
        message: String,
        in viewController: UIViewController? = nil,
        handler: AlertViewContent.Action? = nil
    ) {
        Execution.MainQueue.dispatch {
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
    @objc
    public func standardNotify(
        title: String,
        message: String,
        actions: [UIAlertAction],
        in viewController: UIViewController? = nil
    ) {
        Execution.MainQueue.dispatch {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            actions.forEach { alert.addAction($0) }
            if actions.isEmpty {
                alert.addAction(UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil))
            }
            self.standardNotify(alert: alert, in: viewController)
        }
    }

    public func notify(content: AlertViewContent, in viewController: UIViewController? = nil) {
        standardNotify(title: content.title, message: content.message, actions: content.actions, in: viewController)
    }

    // MARK: - Error

    /// Notify the user on error that occurred
    public func error(
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

    // MARK: - Internet Connection

    @objc
    public func internetConnection() {
        internetConnection(completion: nil)
    }

    @objc
    public func internetConnection(in viewController: UIViewController? = nil, completion: (() -> Void)? = nil) {
        standardNotify(
            title: LocalizationConstants.Errors.error,
            message: LocalizationConstants.Errors.noInternetConnection,
            in: viewController
        ) { [weak self] _ in
            self?.loadingViewPresenter.hide()
            completion?()
        }
    }

    /// Displays the standard error alert
    @objc
    public func standardError(
        title: String = LocalizationConstants.Errors.error,
        message: String,
        in viewController: UIViewController? = nil,
        handler: AlertViewContent.Action? = nil
    ) {
        standardNotify(
            title: title,
            message: message,
            in: viewController,
            handler: handler
        )
    }

    // MARK: - Dismissal

    /// Dismisses an alert if needed
    public func dismissIfNeeded(completion: (() -> Void)? = nil) {
        guard let viewController = topMostViewControllerProvider.topMostViewController else {
            completion?()
            return
        }
        guard let alertController = viewController.presentedViewController as? UIAlertController else {
            completion?()
            return
        }
        alertController.dismiss(animated: true, completion: completion)
    }

    public func standardNotify(alert: UIAlertController, in viewController: UIViewController? = nil) {
        Execution.MainQueue.dispatch {
            guard let topMostViewController = self.topMostViewControllerProvider.topMostViewController else {
                return
            }

            let presentingVC = viewController ?? topMostViewController
            self.present(alert: alert, from: presentingVC)
        }
    }

    // MARK: - Private Accessors

    /// Dismisses an alert controller if currently presented.
    /// Since only one alert is allowed at the same time, we need to dismiss
    /// the currently displayed alert in case another one should be displayed
    private func present(alert: UIAlertController, from presentingVC: UIViewController) {
        guard let previousAlertController = presentingVC.presentedViewController as? UIAlertController else {
            presentingVC.present(alert, animated: true, completion: nil)
            return
        }
        previousAlertController.dismiss(animated: false) {
            presentingVC.present(alert, animated: true, completion: nil)
        }
    }
}
