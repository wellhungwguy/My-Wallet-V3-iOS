// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation
import NetworkKit

public final class CardClient: CardClientAPI {

    // MARK: - Types

    private enum Path: String {
        case cards
        case sensitiveDetailsToken = "marqeta-card-widget-token"
        case account
        case settings
        case eligibleAccounts = "eligible-accounts"
        case lock
        case unlock
        case digitalWallets = "digital-wallets"
        case applePay = "apple-pay"
        case fulfillment
        case pinWidget = "pin-widget-url"
        case activateWidget = "activate-widget-url"
        case statements = "statements"
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - API

    func orderCard(with parameters: OrderCardParameters) -> AnyPublisher<Card, NabuNetworkError> {
        let request = requestBuilder.post(
            path: [Path.cards.rawValue],
            body: try? parameters.encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Card.self)
            .eraseToAnyPublisher()
    }

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [Card].self)
            .eraseToAnyPublisher()
    }

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, id],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Card.self)
            .eraseToAnyPublisher()
    }

    func deleteCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        let request = requestBuilder.delete(
            path: [Path.cards.rawValue, id],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Card.self)
            .eraseToAnyPublisher()
    }

    /// external token to be used in card plugin to retrieve PCI DSS scope card details, PAN, CVV
    func generateSensitiveDetailsToken(with cardId: String) -> AnyPublisher<String, NabuNetworkError> {
        let request = requestBuilder.post(
            path: [Path.cards.rawValue, cardId, Path.sensitiveDetailsToken.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: SensitiveDetailsTokenResponse.self)
            .map(\.token)
            .eraseToAnyPublisher()
    }

    func fetchLinkedAccount(with cardId: String) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.account.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: AccountCurrency.self)
            .eraseToAnyPublisher()
    }

    /// array of linked accounts in priority order
    func updateAccount(
        with parameters: AccountCurrency,
        for cardId: String
    ) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        let request = requestBuilder.put(
            path: [Path.cards.rawValue, cardId, Path.account.rawValue],
            body: try? parameters.encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: AccountCurrency.self)
            .eraseToAnyPublisher()
    }

    func eligibleAccounts(for cardId: String) -> AnyPublisher<[AccountBalance], NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.eligibleAccounts.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [AccountBalance].self)
            .eraseToAnyPublisher()
    }

    func lock(cardId: String) -> AnyPublisher<Card, NabuNetworkError> {
        let request = requestBuilder.put(
            path: [Path.cards.rawValue, cardId, Path.lock.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Card.self)
            .eraseToAnyPublisher()
    }

    func unlock(cardId: String) -> AnyPublisher<Card, NabuNetworkError> {
        let request = requestBuilder.put(
            path: [Path.cards.rawValue, cardId, Path.unlock.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Card.self)
            .eraseToAnyPublisher()
    }

    func tokenise(cardId: String, with parameters: TokeniseCardParameters) -> AnyPublisher<TokeniseCardResponse, NabuNetworkError> {
        let request = requestBuilder.post(
            path: [Path.cards.rawValue, cardId, Path.digitalWallets.rawValue, Path.applePay.rawValue],
            body: try? parameters.encode(),
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: TokeniseCardResponse.self)
            .eraseToAnyPublisher()
    }

    func fulfillment(cardId: String) -> AnyPublisher<Card.Fulfillment, NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.fulfillment.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: Card.Fulfillment.self)
            .eraseToAnyPublisher()
    }

    func pinWidgetUrl(cardId: String) -> AnyPublisher<URL, Errors.NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, cardId, Path.pinWidget.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: FetchUrlResponse.self)
            .map(\.url)
            .eraseToAnyPublisher()
    }

    func activateWidgetUrl(cardId: String) -> AnyPublisher<URL, Errors.NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, Path.activateWidget.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: FetchUrlResponse.self)
            .map(\.url)
            .eraseToAnyPublisher()
    }

    func fetchStatements() -> AnyPublisher<[FeatureCardIssuingDomain.Statement], Errors.NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, Path.statements.rawValue],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: [Statement].self)
            .eraseToAnyPublisher()
    }

    func fetchStatementUrl(statementId: String) -> AnyPublisher<URL, Errors.NabuNetworkError> {
        let request = requestBuilder.get(
            path: [Path.cards.rawValue, Path.statements.rawValue, statementId],
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request, responseType: FetchUrlResponse.self)
            .map(\.url)
            .eraseToAnyPublisher()
    }
}
