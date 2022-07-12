// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RIBs
import RxSwift
import ToolKit
import UIKit

protocol TransactionFlowPresentableListener: AnyObject {
    func closeFlow()
}

protocol TransactionFlowPresentable: Presentable {
    var listener: TransactionFlowPresentableListener? { get set }
}

final class TransactionFlowInitialViewController: BaseScreenViewController {}

final class TransactionFlowViewController: UINavigationController,
    TransactionFlowPresentable,
    TransactionFlowViewControllable
{

    let activityIndicator = UIActivityIndicatorView(style: .medium)

    weak var listener: TransactionFlowPresentableListener?

    init() {
        let root = TransactionFlowInitialViewController()
        root.barStyle = .darkContent()
        super.init(nibName: nil, bundle: nil)
        viewControllers = [root]
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.fillSuperview()

        // so that we'll be able to listen for system dismissal methods
        presentationController?.delegate = self
    }

    func replaceRoot(viewController: ViewControllable?, animated: Bool) {
        activityIndicator.isHidden = viewController != nil
        guard let viewController = viewController else {
            return
        }
        setViewControllers([viewController.uiviewController], animated: animated)
    }

    func present(viewController: ViewControllable?, animated: Bool) {
        activityIndicator.isHidden = viewController != nil
        guard let viewController = viewController else {
            return
        }
        let navigationController: UINavigationController
        if let navController = viewController as? UINavigationController {
            navigationController = navController
        } else {
            navigationController = UINavigationController(rootViewController: viewController.uiviewController)
        }
        present(navigationController, animated: animated, completion: nil)
    }

    func push(viewController: ViewControllable?) {
        activityIndicator.isHidden = viewController != nil
        guard let viewController = viewController else {
            return
        }
        pushViewController(viewController.uiviewController, animated: true)
    }

    func pop() {
        if presentedViewController != nil {
            dismiss()
        } else {
            popViewController(animated: true)
        }
    }

    func popToRoot() {
        if presentedViewController != nil {
            dismiss()
        } else {
            popToRootViewController(animated: true)
        }
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension TransactionFlowViewController: UIAdaptivePresentationControllerDelegate {
    /// Called when a pull-down dismissal happens
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        listener?.closeFlow()
    }
}
