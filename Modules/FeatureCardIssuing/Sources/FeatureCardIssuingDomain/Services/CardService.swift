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
        at address: Card.Address,
        with ssn: String
    ) -> AnyPublisher<Card, NabuNetworkError> {
        repository.orderCard(product: product, at: address, with: ssn)
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

    func generatePinToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        repository.generatePinToken(for: card)
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
}
