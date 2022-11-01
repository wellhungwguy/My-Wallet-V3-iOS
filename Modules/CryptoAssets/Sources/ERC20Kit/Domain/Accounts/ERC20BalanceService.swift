// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import PlatformKit
import ToolKit

/// Protocol for a service in charge of getting ERC-20 balances associated with a given ethereum account address.
public protocol ERC20BalanceServiceAPI {

    /// Gets the balance for the given ethereum account address and the given ERC-20 crypto currency.
    ///
    /// - Parameters:
    ///   - address:        The ethereum account address to get the balance for.
    ///   - cryptoCurrency: The ERC-20 crypto currency to get the balance for.
    ///
    /// - Returns: A publisher that emits the balance on success, or a `ERC20TokenAccountsError` on failure.
    func balance(
        for address: EthereumAddress,
        cryptoCurrency: CryptoCurrency,
        network: EVMNetworkConfig
    ) -> AnyPublisher<CryptoValue, ERC20TokenAccountsError>

    /// Streams the balance for the given ethereum account address and the given ERC-20 crypto currency, including any subsequent updates.
    ///
    /// - Parameters:
    ///   - address:        The ethereum account address to get the balance for.
    ///   - cryptoCurrency: The ERC-20 crypto currency to get the balance for.
    ///
    /// - Returns: A publisher that streams the balance or a `ERC20TokenAccountsError`, including any subsequent updates.
    func balanceStream(
        for address: EthereumAddress,
        cryptoCurrency: CryptoCurrency,
        network: EVMNetworkConfig
    ) -> StreamOf<CryptoValue, ERC20TokenAccountsError>
}

/// A service in charge of getting ERC-20 balances associated with a given ethereum account address.
final class ERC20BalanceService: ERC20BalanceServiceAPI {

    // MARK: - Private Properties

    private let tokenAccountsRepository: ERC20BalancesRepositoryAPI

    // MARK: - Setup

    /// Creates an ERC-20 balance service.
    ///
    /// - Parameter tokenAccountsRepository: An ERC-20 token accounts repository.
    init(tokenAccountsRepository: ERC20BalancesRepositoryAPI) {
        self.tokenAccountsRepository = tokenAccountsRepository
    }

    // MARK: - Internal Methods

    func balance(
        for address: EthereumAddress,
        cryptoCurrency: CryptoCurrency,
        network: EVMNetworkConfig
    ) -> AnyPublisher<CryptoValue, ERC20TokenAccountsError> {
        tokenAccountsRepository.tokens(for: address, network: network)
            .map { accounts in
                accounts[cryptoCurrency]?.balance ?? .zero(currency: cryptoCurrency)
            }
            .eraseToAnyPublisher()
    }

    func balanceStream(
        for address: EthereumAddress,
        cryptoCurrency: CryptoCurrency,
        network: EVMNetworkConfig
    ) -> StreamOf<CryptoValue, ERC20TokenAccountsError> {
        tokenAccountsRepository.tokensStream(for: address, network: network)
            .map { result in
                switch result {
                case .failure(let error):
                    return .failure(error)
                case .success(let accounts):
                    return .success(accounts[cryptoCurrency]?.balance ?? .zero(currency: cryptoCurrency))
                }
            }
            .eraseToAnyPublisher()
    }
}
