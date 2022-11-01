// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import EthereumKit
import MoneyKit

/// A ERC20 Activity Repository for Ethereum network only.
public protocol ERC20ActivityRepositoryAPI {

    func transactions(
        erc20Asset: AssetModel,
        address: EthereumAddress
    ) -> AnyPublisher<[ERC20HistoricalTransaction], NetworkError>
}
