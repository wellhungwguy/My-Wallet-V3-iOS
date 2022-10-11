// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureInterestDomain
import FeatureTransactionUI
import PlatformKit

struct InterestAccountSelectionEnvironment {
    let fiatCurrencyService: FiatCurrencyServiceAPI
    let accountOverviewRepository: InterestAccountOverviewRepositoryAPI
    let accountBalanceRepository: InterestAccountBalanceRepositoryAPI
    let accountRepository: BlockchainAccountRepositoryAPI
    let priceService: PriceServiceAPI
    let blockchainAccountRepository: BlockchainAccountRepositoryAPI
    let kycVerificationService: KYCVerificationServiceAPI
    let transactionRouterAPI: TransactionsRouterAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

extension InterestAccountSelectionEnvironment {
    static let `default`: InterestAccountSelectionEnvironment = .init(
        fiatCurrencyService: resolve(),
        accountOverviewRepository: resolve(),
        accountBalanceRepository: resolve(),
        accountRepository: resolve(),
        priceService: resolve(),
        blockchainAccountRepository: resolve(),
        kycVerificationService: resolve(),
        transactionRouterAPI: resolve(),
        analyticsRecorder: resolve(),
        mainQueue: .main
    )
}
