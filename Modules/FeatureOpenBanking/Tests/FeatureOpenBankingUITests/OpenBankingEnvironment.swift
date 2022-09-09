// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainUI
import FeatureOpenBankingTestFixture
@testable import FeatureOpenBankingUI
import NetworkKit

extension OpenBankingEnvironment {

    public static func test(
        app: AppProtocol,
        scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.test.eraseToAnyScheduler(),
        showTransferDetails: @escaping () -> Void = {},
        dismiss: @escaping () -> Void = {},
        openURL: @escaping (URL) -> Void = { _ in }
    ) -> (environment: OpenBankingEnvironment, network: ReplayNetworkCommunicator) {
        let (banking, network) = OpenBanking.test(app: app, using: scheduler)
        return (
            OpenBankingEnvironment(
                app: app,
                scheduler: scheduler,
                openBanking: banking,
                showTransferDetails: showTransferDetails,
                dismiss: dismiss,
                openURL: OpenURL(yield: openURL),
                fiatCurrencyFormatter: NoFormatCurrencyFormatter(),
                cryptoCurrencyFormatter: NoFormatCurrencyFormatter(),
                analytics: TestEventRecorder(),
                currency: "GBP"
            ),
            network
        )
    }
}

final class TestEventRecorder: AnalyticsEventRecorderAPI {

    var recorded: [AnalyticsEvent] = []

    func record(event: AnalyticsEvent) {
        recorded.append(event)
    }

    func record(events: [AnalyticsEvent]) {
        for event in events {
            record(event: event)
        }
    }
}
