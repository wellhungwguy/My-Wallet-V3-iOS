// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import PassKit

final class CardService: CardServiceAPI {

    private let repository: CardRepositoryAPI

    init(
        repository: CardRepositoryAPI
    ) {
        self.repository = repository
    }

    func orderCard(
        product: Product,
        at address: Card.Address?
    ) -> AnyPublisher<Card, NabuNetworkError> {
        repository.orderCard(product: product, at: address)
    }

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError> {
        repository.fetchCards()
    }

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError> {
        repository.fetchCard(with: id)
    }

    func delete(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        repository.delete(card: card)
    }

    func helperUrl(for card: Card) -> AnyPublisher<URL, NabuNetworkError> {
        repository.helperUrl(for: card)
    }

    func fetchLinkedAccount(for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        repository.fetchLinkedAccount(for: card)
    }

    func update(account: AccountBalance, for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        repository.update(account: account, for: card)
    }

    func eligibleAccounts(for card: Card) -> AnyPublisher<[AccountBalance], NabuNetworkError> {
        repository.eligibleAccounts(for: card)
    }

    func lock(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        repository.lock(card: card)
    }

    func unlock(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        repository.unlock(card: card)
    }

    func tokenise(
        card: Card,
        with certificates: [Data],
        nonce: Data,
        nonceSignature: Data
    ) -> AnyPublisher<PKAddPaymentPassRequest, NabuNetworkError> {
        repository.tokenise(card: card, with: certificates, nonce: nonce, nonceSignature: nonceSignature)
    }

    func fulfillment(card: Card) -> AnyPublisher<Card.Fulfillment, NabuNetworkError> {
        repository.fulfillment(card: card)
    }

    func pinWidgetUrl(card: Card) -> AnyPublisher<URL, NabuNetworkError> {
        repository.pinWidgetUrl(card: card)
    }

    func activateWidgetUrl(card: Card) -> AnyPublisher<URL, NabuNetworkError> {
        repository.activateWidgetUrl(card: card)
    }

    func fetchStatements() -> AnyPublisher<[Statement], NabuNetworkError> {
        repository.fetchStatements()
    }

    func fetchStatementUrl(statement: Statement) -> AnyPublisher<URL, NabuNetworkError> {
        repository.fetchStatementUrl(statement: statement)
    }
}
