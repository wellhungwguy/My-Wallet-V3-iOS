// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import ERC20DataKit
import Errors
import EthereumKit
import MoneyKit
import PlatformKit

final class ERC20BalancesClientMock: ERC20BalancesClientAPI {

    // MARK: - Types

    enum Behaviour {
        case succeed
        case fail
        case failThenSucceed
    }

    // MARK: - Properties

    var behaviour: Behaviour

    // MARK: - Private Properties

    private let cryptoCurrency: CryptoCurrency
    private var evmTokensBalancesCallCount: Int = 0
    private var ethereumTokensBalancesCallCount: Int = 0

    // MARK: - Setup

    /// Creates a mock ERC-20 account client
    ///
    /// - Parameters:
    ///   - cryptoCurrency: An ERC-20 crypto currency.
    ///   - errorAddress:   An error address.
    init(
        cryptoCurrency: CryptoCurrency,
        behaviour: Behaviour
    ) {
        self.cryptoCurrency = cryptoCurrency
        self.behaviour = behaviour
    }

    // MARK: - Internal Methods

    func evmTokensBalances(
        for address: String,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EVMBalancesResponse, NetworkError> {
        switch behaviour {
        case .succeed:
            return .just(.stubbed(cryptoCurrency: cryptoCurrency))
        case .fail:
            return .failure(.unknown)
        case .failThenSucceed:
            defer { evmTokensBalancesCallCount += 1 }
            switch evmTokensBalancesCallCount {
            case 0:
                return .failure(.unknown)
            case 1:
                return .just(.stubbed(cryptoCurrency: cryptoCurrency))
            default:
                fatalError("Don't reuse between tests.")
            }
        }
    }

    func ethereumTokensBalances(
        for address: String
    ) -> AnyPublisher<ERC20TokenAccountsResponse, NetworkError> {
        switch behaviour {
        case .succeed:
            return .just(.stubbed(cryptoCurrency: cryptoCurrency))
        case .fail:
            return .failure(.unknown)
        case .failThenSucceed:
            defer { ethereumTokensBalancesCallCount += 1 }
            switch ethereumTokensBalancesCallCount {
            case 0:
                return .failure(.unknown)
            case 1:
                return .just(.stubbed(cryptoCurrency: cryptoCurrency))
            default:
                fatalError("Don't reuse between tests.")
            }
        }
    }
}
