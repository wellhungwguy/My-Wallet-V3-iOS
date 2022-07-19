//
//  AccountsRouter.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import FeatureDashboardUI
import FeatureInterestUI
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class AccountsRouter: AccountsRouting {

    private let custodyActionRouterAPI: CustodyActionRouterAPI
    private let disposeBag = DisposeBag()

    init(
        routing: TabSwapping,
        backupRouter: FeatureDashboardUI.BackupRouterAPI = resolve()
    ) {
        let provider = CustodyActionRouterProvider()
        custodyActionRouterAPI = provider.create(
            backupRouterAPI: backupRouter,
            tabSwapping: routing
        )
    }

    private func routeToInterestAccount(for account: BlockchainAccount) {
        let interactor = InterestAccountDetailsScreenInteractor(account: account)
        let presenter = InterestAccountDetailsScreenPresenter(
            interactor: interactor
        )
        let controller = InterestAccountDetailsViewController(presenter: presenter)

        let navigationRouter: NavigationRouterAPI = resolve()
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }

    func route(to account: BlockchainAccount) {
        switch account {
        case is CryptoInterestAccount:
            routeToInterestAccount(for: account)
        case is TradingAccount,
             is FiatAccount:
            custodyActionRouterAPI.start(with: account)
        default:
            unimplemented("Unsupported account type \(String(reflecting: account))")
        }
    }
}
