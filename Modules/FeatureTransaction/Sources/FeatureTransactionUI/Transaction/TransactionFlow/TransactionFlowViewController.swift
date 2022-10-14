// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DIKit
import PlatformUIKit
import RIBs
import RxSwift
import SwiftUI
import ToolKit
import UIKit

protocol TransactionFlowPresentableListener: AnyObject {
    func closeFlow()
}

protocol TransactionFlowPresentable: Presentable {
    var listener: TransactionFlowPresentableListener? { get set }
}

final class TransactionFlowInitialViewController: BaseScreenViewController {

    let app: AppProtocol = resolve()

    override func viewDidLoad() {
        super.viewDidLoad()
        let hosting = UIHostingController(rootView: LoadingTransactionFlowView().app(app))
        add(child: hosting)
        hosting.view.fillSuperview()
    }
}

final class TransactionFlowViewController: UINavigationController,
    TransactionFlowPresentable,
    TransactionFlowViewControllable
{

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
        // so that we'll be able to listen for system dismissal methods
        presentationController?.delegate = self
    }

    @objc func close() {
        dismiss()
    }

    func replaceRoot(viewController: ViewControllable?, animated: Bool) {
        guard let viewController = viewController else {
            return
        }
        setViewControllers([viewController.uiviewController], animated: animated)
    }

    func present(viewController: ViewControllable?, animated: Bool) {
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

@MainActor
private struct LoadingTransactionFlowView: View {

    @BlockchainApp var app
    @Environment(\.context) var context
    @Environment(\.scheduler) var scheduler

    @State private var showClose = false

    var body: some View {
        ZStack {
            VStack {
                BlockchainProgressView()
                if showClose {
                    DestructivePrimaryButton(title: "Close") {
                        app.post(event: blockchain.ux.transaction.loading.close.tap.then.close, context: context)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            app.post(event: blockchain.ux.transaction.loading, context: context)
        }
        .task {
            do {
                try await scheduler.sleep(for: .seconds(15))
                showClose = true
            } catch { }
        }
    }
}
