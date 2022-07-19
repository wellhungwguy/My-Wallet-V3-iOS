// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureActivityDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import SafariServices

final class ActivityRouter: ActivityRouterAPI {

    private let serviceContainer: ActivityServiceContaining
    private let transactionDetailService: TransactionDetailServiceAPI
    private let navigationRouter: NavigationRouterAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private var router: AccountPickerRouting!

    init(
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        container: ActivityServiceContaining = resolve(),
        transactionDetailService: TransactionDetailServiceAPI = resolve()
    ) {
        self.navigationRouter = navigationRouter
        serviceContainer = container
        self.enabledCurrenciesService = enabledCurrenciesService
        self.transactionDetailService = transactionDetailService
    }

    func showWalletSelectionScreen() {
        let builder = AccountPickerBuilder(
            singleAccountsOnly: false,
            action: .viewActivity
        )
        let didSelect: AccountPickerDidSelect = { [weak self] account in
            self?.didSelect(account: account)
        }
        router = builder.build(
            listener: .simple(didSelect),
            navigationModel: ScreenNavigationModel.AccountPicker.modal(),
            headerModel: .none
        )

        router.interactable.activate()
        router.load()
        navigationRouter.present(viewController: router.viewControllable.uiviewController)
    }

    private func didSelect(account: BlockchainAccount) {
        serviceContainer.selectionService.record(selection: account)
        router.viewControllable.uiviewController.dismiss(animated: true, completion: nil)
        router = nil
    }

    func showTransactionScreen(with event: ActivityItemEvent) {
        let controller = DetailsScreenViewController(
            presenter: ActivityDetailsPresenterFactory.presenter(for: event, router: self)
        )
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }

    func showBlockchainExplorer(for event: TransactionalActivityItemEvent) {
        let url = transactionDetailService
            .transactionDetailURL(
                for: event.transactionHash,
                cryptoCurrency: event.currency
            )
            .flatMap(URL.init(string:))
        guard let url = url else {
            return
        }
        let controller = SFSafariViewController(url: url)
        controller.modalPresentationStyle = .overFullScreen
        navigationRouter.topMostViewControllerProvider.topMostViewController?.present(
            controller,
            animated: true,
            completion: nil
        )
    }

    func showActivityShareSheet(_ event: ActivityItemEvent) {
        let viewModel = ActivityMessageViewModel(
            event: event
        )
        guard let model = viewModel else { return }
        let view = ActivityMessageView(
            frame: .init(
                origin: .zero,
                size: .init(
                    width: 275.0,
                    height: 300.0
                )
            )
        )
        view.viewModel = model

        guard let image = view.imageRepresentation else { return }
        guard let root = navigationRouter.topMostViewControllerProvider.topMostViewController else { return }
        let controller = UIActivityViewController(
            activityItems: [ImageActivityItemSource(image: image)],
            applicationActivities: nil
        )

        root.present(controller, animated: true, completion: nil)
    }
}
