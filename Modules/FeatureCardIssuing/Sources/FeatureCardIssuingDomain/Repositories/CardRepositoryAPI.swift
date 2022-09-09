// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol CardRepositoryAPI {

    func orderCard(product: Product, at address: Card.Address, with ssn: String) -> AnyPublisher<Card, NabuNetworkError>

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError>

    func fetchCard(with id: String) -> AnyPublisher<Card, NabuNetworkError>

    func delete(card: Card) -> AnyPublisher<Card, NabuNetworkError>

    /// generate the URL for the webview to display the card details
    func helperUrl(for card: Card) -> AnyPublisher<URL, NabuNetworkError>

    /// one time token to be used in marqeta widget to reveal or update the card PIN
    func generatePinToken(for card: Card) -> AnyPublisher<String, NabuNetworkError>

    func fetchLinkedAccount(for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError>

    func update(account: AccountBalance, for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError>

    func eligibleAccounts(for card: Card) -> AnyPublisher<[AccountBalance], NabuNetworkError>

    func lock(card: Card) -> AnyPublisher<Card, NabuNetworkError>

    func unlock(card: Card) -> AnyPublisher<Card, NabuNetworkError>
}

public protocol UserInfoProviderAPI {
    var fullName: AnyPublisher<String, NabuNetworkError> { get }
}
