// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import RIBs

// MARK: - Builder

protocol PendingTransactionPageBuildable: Buildable {
    func build(
        withListener listener: PendingTransactionPageListener,
        transactionModel: TransactionModel,
        action: AssetAction
    ) -> PendingTransactionPageRouter
}

final class PendingTransactionPageBuilder: PendingTransactionPageBuildable {

    init() {}

    func build(
        withListener listener: PendingTransactionPageListener,
        transactionModel: TransactionModel,
        action: AssetAction
    ) -> PendingTransactionPageRouter {
        let viewController = PendingTransactionViewController()
        let interactor = PendingTransactionPageInteractor(
            transactionModel: transactionModel,
            presenter: viewController,
            action: action
        )
        interactor.listener = listener

        return PendingTransactionPageRouter(interactor: interactor, viewController: viewController)
    }
}
