// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureTransactionDomain
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift

final class ReceiveRouter: ReceiveRouterAPI {
    private typealias LocalizedString = LocalizationConstants.Receive

    private let navigationRouter: NavigationRouterAPI
    private let webViewService: WebViewServiceAPI
    private let kycRouter: PlatformUIKit.KYCRouting
    private let restrictionsProvider: TransactionRestrictionsProviderAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()

    init(
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        webViewService: WebViewServiceAPI = resolve(),
        kycRouter: PlatformUIKit.KYCRouting = resolve(),
        restrictionsProvider: TransactionRestrictionsProviderAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.navigationRouter = navigationRouter
        self.webViewService = webViewService
        self.kycRouter = kycRouter
        self.restrictionsProvider = restrictionsProvider
        self.analyticsRecorder = analyticsRecorder
    }

    func presentReceiveScreen(for account: BlockchainAccount) {
        guard let account = account as? SingleAccount else {
            return
        }
        let interactor = ReceiveScreenInteractor(account: account)
        let presenter = ReceiveScreenPresenter(interactor: interactor)
        let receive = ReceiveScreenViewController(presenter: presenter)
        let nav = UINavigationController(rootViewController: receive)
        presenter.webViewLaunchRelay
            .bind { [weak self] url in
                self?.webViewService.openSafari(url: url, from: receive)
            }
            .disposed(by: disposeBag)
        navigationRouter.present(viewController: nav)
        analyticsRecorder.record(event: AnalyticsEvents.New.Send.sendReceiveViewed(type: .receive))
    }

    func presentKYCScreen() {
        guard let presenter = navigationRouter.topMostViewControllerProvider.topMostViewController else {
            return
        }
        kycRouter.presentKYCUpgradeFlow(from: presenter)
            .asSingle()
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe { _ in
                // the call dismisses view automatically
            }
            .disposed(by: disposeBag)
    }

    func shareDetails(for metadata: QRCodeMetadata, currencyType: CurrencyType) {
        let displayCode = currencyType.displayCode
        let prefix = String(format: LocalizedString.Text.pleaseSendXTo, displayCode)
        let message = "\(prefix) \(metadata.content)"
        let subject = String(format: LocalizedString.Text.xPaymentRequest, displayCode)
        let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList, .postToFacebook]
        activityViewController.setValue(subject, forKey: "subject")
        navigationRouter.present(viewController: activityViewController)
    }
}
