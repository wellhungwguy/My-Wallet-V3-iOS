// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import RxSwift

public protocol PaymentAccountServiceAPI: AnyObject {

    /// Fetch the Payment Account information for the currency wallet's fiat currency
    var paymentAccount: Single<PaymentAccountDescribing> { get }

    /// Fetch the Payment Account information for the given currency.
    func paymentAccount(for currency: FiatCurrency) -> Single<PaymentAccountDescribing>
}

final class PaymentAccountService: PaymentAccountServiceAPI {

    // MARK: - Types

    private enum ServiceError: Error {
        case invalidResponse
    }

    // MARK: - Public Properties

    /// Using a currency service, get the currency currency and check if the user has a
    /// payment account for the currenctly set fiat currency
    var paymentAccount: Single<PaymentAccountDescribing> {
        fiatCurrencyService.tradingCurrency
            .asSingle()
            .flatMap(weak: self) { (self, currency) in
                self.paymentAccount(for: currency)
            }
    }

    // MARK: - Private Properties

    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let client: PaymentAccountClientAPI
    private let dataRepository: DataRepositoryAPI
    private let patcher: PaymentAccountPatcher

    // MARK: - Setup

    init(
        client: PaymentAccountClientAPI = resolve(),
        dataRepository: DataRepositoryAPI = resolve(),
        fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
        patcher: PaymentAccountPatcher = PaymentAccountPatcher()
    ) {
        self.client = client
        self.fiatCurrencyService = fiatCurrencyService
        self.dataRepository = dataRepository
        self.patcher = patcher
    }

    // MARK: - Public Methods

    func paymentAccount(for currency: FiatCurrency) -> Single<PaymentAccountDescribing> {
        fetchPaymentAccount(for: currency, patcher: patcher)
    }

    // MARK: - Private Methods

    func fetchPaymentAccount(
        for currency: FiatCurrency,
        patcher: PaymentAccountPatcher
    ) -> Single<PaymentAccountDescribing> {
        dataRepository.user.eraseError()
            .zip(client.paymentAccount(for: currency).map(\.account).eraseError())
            .map { user, response -> PaymentAccountDescribing? in
                PaymentAccountBuilder
                    .build(response: response)
                    .map { patcher.patch($0, recipientName: user.personalDetails.fullName) }
            }
            .onNil(ServiceError.invalidResponse)
            .asSingle()
    }
}
