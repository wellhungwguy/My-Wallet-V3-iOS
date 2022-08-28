// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainUI
import DIKit
import FeatureOpenBankingDomain
import SwiftUI

public protocol OpenURLProtocol {
    func open(_ url: URL, completionHandler: @escaping (Bool) -> Void)
}
extension OpenURLProtocol {
    func open(_ url: URL) { open(url, completionHandler: { _ in }) }
}

struct LogOpenURL: OpenURLProtocol {
    func open(_ url: URL, completionHandler: @escaping (Bool) -> Void) {
        url.peek("🫙 Open URL")
        completionHandler(true)
    }
}

public struct OpenBankingEnvironment {

    public var environment: Self { self }
    public private(set) var eventPublisher = PassthroughSubject<Result<Void, OpenBanking.Error>, Never>()

    public var app: AppProtocol
    public var scheduler: AnySchedulerOf<DispatchQueue>
    public var openBanking: OpenBanking
    public var showTransferDetails: () -> Void
    public var dismiss: () -> Void
    public var cancel: () -> Void
    public var openURL: OpenURLProtocol
    public var fiatCurrencyFormatter: FiatCurrencyFormatter
    public var cryptoCurrencyFormatter: CryptoCurrencyFormatter
    public var analytics: AnalyticsEventRecorderAPI

    public init(
        app: AppProtocol,
        scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler(),
        openBanking: OpenBanking = resolve(),
        showTransferDetails: @escaping () -> Void = {},
        dismiss: @escaping () -> Void = {},
        cancel: @escaping () -> Void = {},
        openURL: OpenURLProtocol = resolve(),
        fiatCurrencyFormatter: FiatCurrencyFormatter = resolve(),
        cryptoCurrencyFormatter: CryptoCurrencyFormatter = resolve(),
        analytics: AnalyticsEventRecorderAPI = resolve(),
        currency: String
    ) {
        self.app = app
        self.scheduler = scheduler
        self.openBanking = openBanking
        self.showTransferDetails = showTransferDetails
        self.dismiss = dismiss
        self.cancel = cancel
        self.openURL = openURL
        self.fiatCurrencyFormatter = fiatCurrencyFormatter
        self.cryptoCurrencyFormatter = cryptoCurrencyFormatter
        self.analytics = analytics

        app.state.set(blockchain.ux.payment.method.open.banking.currency, to: currency)
    }
}
