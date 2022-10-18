// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ERC20Kit
import EthereumKit
import MoneyKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20BalanceServiceMock: ERC20BalanceServiceAPI {

    // MARK: - Private Properties

    private let balance: CryptoValue

    // MARK: - Setup

    /// Creates a mock ERC-20 balance service.
    ///
    /// - Parameter cryptoCurrency: An ERC-20 crypto currency.
    init(cryptoCurrency: CryptoCurrency) {
        balance = .create(majorBigInt: 2, currency: cryptoCurrency)
    }

    // MARK: - Internal Methods

    func balance(
        for address: EthereumAddress,
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<CryptoValue, ERC20TokenAccountsError> {
        .just(balance)
    }

    func balanceStream(
        for address: EthereumAddress,
        cryptoCurrency: CryptoCurrency
    ) -> StreamOf<CryptoValue, ERC20TokenAccountsError> {
        .just(.success(balance))
    }
}
