// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import RxRelay
import RxSwift
import RxToolKit
import ToolKit
import WalletPayloadKit

final class EligibilityService: EligibilityServiceAPI {

    // MARK: - Properties

    var isEligiblePublisher: AnyPublisher<Bool, Never> {
        isEligible
            .asPublisher()
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    var isEligible: Single<Bool> {
        isEligibileValue
            .valueSingle
            .map(\.eligible)
    }

    private let isEligibileValue: CachedValue<Eligibility>
    private let client: EligibilityClientAPI
    private let reactiveWallet: ReactiveWalletAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI

    // MARK: - Setup

    init(
        client: EligibilityClientAPI = resolve(),
        reactiveWallet: ReactiveWalletAPI = resolve(),
        fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve()
    ) {
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.fiatCurrencyService = fiatCurrencyService
        self.isEligibileValue = CachedValue(
            configuration: .periodic(
                seconds: 30,
                schedulerIdentifier: "EligibilityService"
            )
        )

        isEligibileValue.setFetch(weak: self) { (self) in
            self.reactiveWallet.waitUntilInitializedFirst
                .asObservable()
                .take(1)
                .asSingle()
                .flatMap(weak: self) { (self, _) -> Single<Eligibility> in
                    self.fiatCurrencyService.tradingCurrency
                        .asSingle()
                        .flatMap { currency -> Single<Eligibility> in
                            self.client.isEligible(
                                for: currency.code,
                                methods: [
                                    PaymentMethodPayloadType.bankTransfer.rawValue,
                                    PaymentMethodPayloadType.card.rawValue
                                ]
                            )
                            .map { response in
                                Eligibility(
                                    eligible: response.eligible,
                                    simpleBuyTradingEligible: response.simpleBuyTradingEligible,
                                    simpleBuyPendingTradesEligible: response.simpleBuyPendingTradesEligible,
                                    pendingDepositSimpleBuyTrades: response.pendingDepositSimpleBuyTrades,
                                    pendingConfirmationSimpleBuyTrades: response.pendingConfirmationSimpleBuyTrades,
                                    maxPendingDepositSimpleBuyTrades: response.maxPendingDepositSimpleBuyTrades,
                                    maxPendingConfirmationSimpleBuyTrades: response.maxPendingConfirmationSimpleBuyTrades
                                )
                            }
                            .asSingle()
                        }
                }
        }
    }

    func fetch() -> Single<Bool> {
        isEligibileValue.fetchValue
            .map(\.eligible)
    }

    func eligibility() -> AnyPublisher<Eligibility, Error> {
        isEligibileValue.fetchValue
            .asPublisher()
            .eraseToAnyPublisher()
    }
}
