// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureCardPaymentDomain
import PlatformKit

private class CardClientMock: CardClientAPI {
    private let cardClient: CardClientAPI

    init(cardClient: CardClientAPI = resolve()) {
        self.cardClient = cardClient
    }

    func getCardList(enableProviders: Bool) -> AnyPublisher<[CardPayload], NabuNetworkError> {
        cardClient.getCardList(enableProviders: true)
    }

    func chargeCard(by id: String) -> AnyPublisher<Void, NabuNetworkError> {
        cardClient.chargeCard(by: id)
    }

    func deleteCard(by id: String) -> AnyPublisher<Void, NabuNetworkError> {
        cardClient.deleteCard(by: id)
    }

    func getCardSuccessRate(
        binNumber: String
    ) -> AnyPublisher<CardSuccessRate.Response, NabuNetworkError> {
        cardClient.getCardSuccessRate(binNumber: binNumber)
    }

    func activateCard(
        by id: String,
        url: String,
        cvv: String
    ) -> AnyPublisher<ActivateCardResponse.Partner, NabuNetworkError> {
        let pk = "pk_test_51JhAakHxBe1tOCzxhX2cvybhcCPMMXfQQghkI7X9VEUFMTyL" +
            "vcyLVFXSkM9bjsynKmRRwLwkalcPrWJeGaNriU6S00x8XQ9VLX"
        let partner: ActivateCardResponse.Partner = .cardAcquirer(.init(
            cardAcquirerName: .stripe,
            cardAcquirerAccountCode: "stripe_uk",
            apiUserID: nil,
            apiToken: nil,
            paymentLink: nil,
            paymentState: "WAITING_FOR_3DS_RESPONSE",
            paymentReference: nil,
            orderReference: nil,
            clientSecret: "pi_3JxYDPHxBe1tOCzx0eL6Zo8u_secret_jgjGD59uSZZ4Hgc8QodCpIYwx",
            publishableApiKey: pk
        ))

        return .just(partner)
    }

    func getCard(by id: String) -> AnyPublisher<CardPayload, NabuNetworkError> {
        cardClient.getCard(by: id)
    }

    func add(
        for currency: String,
        email: String,
        billingAddress: CardPayload.BillingAddress,
        paymentMethodTokens: [String: String]
    ) -> AnyPublisher<CardPayload, NabuNetworkError> {
        .just(
            CardPayload(
                identifier: "",
                partner: "CARDPROVIDER",
                address: nil,
                currency: "GBP",
                state: .active,
                card: nil,
                additionDate: ""
            )
        )
    }
}
