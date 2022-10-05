// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit
import RIBs
import UIKit

protocol BuyFlowRouting: Routing {

    func start(with cryptoAccount: CryptoAccount?, order: OrderDetails?, from presenter: UIViewController)
}

final class BuyFlowRouter: RIBs.Router<BuyFlowInteractor>, BuyFlowRouting {

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        interactor: BuyFlowInteractor,
        analyticsRecorder: AnalyticsEventRecorderAPI
    ) {
        self.analyticsRecorder = analyticsRecorder
        super.init(interactor: interactor)
    }

    func start(with cryptoAccount: CryptoAccount?, order: OrderDetails?, from presenter: UIViewController) {
        let builder = TransactionFlowBuilder()
        let router = builder.build(
            withListener: interactor,
            action: .buy,
            sourceAccount: nil,
            target: cryptoAccount,
            order: order
        )
        attachChild(router)
        let viewController = router.viewControllable.uiviewController
        viewController.isModalInPresentation = true
        presenter.present(viewController, animated: true)
    }
}
