import BlockchainNamespace
import Foundation
import ToolKit
import UIKit

public class ActionObserver: Session.Observer {

    unowned var app: AppProtocol
    var application: UIApplication

    public init(app: AppProtocol, application: UIApplication) {
        self.app = app
        self.application = application
    }

    lazy var launchURL = app.on(blockchain.ui.type.action.then.launch.url) { [app, application] event in
        let url = try event.context.decode(blockchain.ui.type.action.then.launch.url, as: URL.self)
        guard app.deepLinks.canProcess(url: url) else {
            return application.open(url)
        }
        app.post(
            event: blockchain.app.process.deep_link,
            context: event.context + [blockchain.app.process.deep_link.url: url]
        )
    }

    lazy var close = app.on(blockchain.ui.type.action.then.close) { [app, application] event in
        if let close = try? app.state.get(event.reference) as Session.State.Function {
            try close()
        } else if let topMostViewController = application.topViewController {
            topMostViewController.dismiss(animated: true)
        } else {
            assertionFailure("Attempted to dismiss \(event.reference), but cannot")
        }
    }

    lazy var actions = [launchURL, close]

    public func start() {
        for action in actions {
            action.start()
        }
    }

    public func stop() {
        for action in actions {
            action.stop()
        }
    }
}

extension UIApplication {
    var topViewController: UIViewController? {
        guard let window = windows.first(where: \.isKeyWindow) else { return nil }
        return Blockchain.topViewController(of: window.rootViewController)
    }
}

private func topViewController(of viewController: UIViewController?) -> UIViewController? {

    if
        let navigationController  = viewController as? UINavigationController,
        let visibleViewController = navigationController.visibleViewController,
        !visibleViewController.isBeingDismissed
    {
        return topViewController(of: visibleViewController)
    }

    if
        let tabBarController = viewController as? UITabBarController,
        let selectedViewController = tabBarController.selectedViewController
    {
        return topViewController(of: selectedViewController)
    }

    if
        let presented = viewController?.presentedViewController,
        !presented.isBeingDismissed
    {
        return topViewController(of: presented)
    }

    return viewController
}
