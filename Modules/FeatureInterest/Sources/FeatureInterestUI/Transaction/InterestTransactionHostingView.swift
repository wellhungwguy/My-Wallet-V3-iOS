// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionUI
import PlatformKit
import RIBs
import SwiftUI
import ToolKit

final class InterestTransactionHostingView: UIViewControllerRepresentable {

    private let account: CryptoInterestAccount
    private let action: AssetAction
    private var transactionFlowRouting: ViewableRouting!

    init(
        state: InterestTransactionState
    ) {
        self.account = state.account
        self.action = state.action
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let builder = TransactionFlowBuilder()
        transactionFlowRouting = builder.build(
            withListener: self,
            action: action,
            sourceAccount: action == .interestWithdraw ? account : nil,
            target: action == .interestTransfer ? account : nil
        )
        transactionFlowRouting.interactable.activate()
        transactionFlowRouting.load()
        return transactionFlowRouting.viewControllable.uiviewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // noop
    }
}

extension InterestTransactionHostingView: TransactionFlowListener {

    func presentKYCFlowIfNeeded(
        from viewController: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        unimplemented()
    }

    func presentKYCUpgradeFlow(
        from viewController: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        unimplemented()
    }

    func dismissTransactionFlow() {
        transactionFlowRouting = nil
    }
}
