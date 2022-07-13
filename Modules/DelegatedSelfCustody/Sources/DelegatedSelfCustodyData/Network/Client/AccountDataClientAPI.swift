// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import NetworkKit

protocol AccountDataClientAPI {
    func balance(
        guidHash: String,
        sharedKeyHash: String,
        fiatCurrency: FiatCurrency,
        currencies: [CryptoCurrency]?
    ) -> AnyPublisher<BalanceResponse, NetworkError>
}

extension Client: AccountDataClientAPI {
    private struct BalanceRequestPayload: Encodable {
        struct CurrencyEntry: Encodable {
            let ticker: String
        }

        let auth: AuthDataPayload
        let currencies: [CurrencyEntry]?
        let fiatCurrency: String
    }

    func balance(
        guidHash: String,
        sharedKeyHash: String,
        fiatCurrency: FiatCurrency,
        currencies: [CryptoCurrency]?
    ) -> AnyPublisher<BalanceResponse, NetworkError> {
        let payload = BalanceRequestPayload(
            auth: AuthDataPayload(guidHash: guidHash, sharedKeyHash: sharedKeyHash),
            currencies: currencies?
                .map(\.code)
                .map(BalanceRequestPayload.CurrencyEntry.init),
            fiatCurrency: fiatCurrency.code
        )
        let request = requestBuilder
            .post(
                path: Endpoint.balance,
                body: try? payload.encode()
            )!

        return networkAdapter
            .perform(request: request)
    }
}
