// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import Errors
import FeatureFormDomain
import FeatureKYCDomain
import Localization
import ToolKit
import UIComponentsKit
import UIKit

final class KYCAccountUsageController: KYCBaseViewController {

    override class func make(with coordinator: KYCRouter) -> KYCBaseViewController {
        let controller = KYCAccountUsageController()
        controller.pageType = .accountUsageForm
        controller.router = coordinator
        return controller
    }

    let app: AppProtocol = DIKit.resolve()
    let analyticsRecorder: AnalyticsEventRecorderAPI = DIKit.resolve()
    let accountUsageService: KYCAccountUsageServiceAPI = DIKit.resolve()

    override func viewDidLoad() {
        super.viewDidLoad()
        embedAccountUsageView()
        title = LocalizationConstants.NewKYC.Steps.AccountUsage.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissWithAnimation)
        )
    }

    private func embedAccountUsageView() {
        let view = AccountUsageView(
            store: .init(
                initialState: AccountUsage.State.idle,
                reducer: AccountUsage.reducer,
                environment: AccountUsage.Environment(
                    onComplete: continueToNextStep,
                    dismiss: dismissWithAnimation,
                    loadForm: { [app] () -> AnyPublisher<Form, Nabu.Error> in
                        app.publisher(for: blockchain.ux.kyc.extra.questions.form.data)
                            .compactMap { data in data.value as? Result<FeatureFormDomain.Form, Nabu.Error> }
                            .get()
                            .prefix(1)
                            .eraseToAnyPublisher()
                    },
                    submitForm: accountUsageService.submitExtraKYCQuestions,
                    analyticsRecorder: analyticsRecorder
                )
            )
        )
        embed(view)
    }

    private func continueToNextStep() {
        router.handle(event: .nextPageFromPageType(pageType, nil))
    }

    @objc private func dismissWithAnimation() {
        app.state.clear(blockchain.ux.kyc.extra.questions.form)
        dismiss(animated: true)
    }

    // MARK: - UI Configuration

    override func navControllerCTAType() -> NavigationCTA {
        .none
    }
}
