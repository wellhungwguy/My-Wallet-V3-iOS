// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ERC20Kit
import Errors
import EthereumKit
import MoneyKit
import PlatformKit
import ToolKit

/// A ERC20 Activity Repository for Ethereum network only.
final class ERC20ActivityRepository: ERC20ActivityRepositoryAPI {

    private struct Key: Hashable {
        let erc20Asset: AssetModel
        let address: EthereumAddress
    }

    private let client: ERC20ActivityClientAPI
    private let cachedValue: CachedValueNew<
        Key,
        [ERC20HistoricalTransaction],
        NetworkError
    >

    init(client: ERC20ActivityClientAPI) {
        self.client = client
        let cache: AnyCache<Key, [ERC20HistoricalTransaction]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        self.cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] key -> AnyPublisher<[ERC20HistoricalTransaction], NetworkError> in
                guard let contractAddress = key.erc20Asset.kind.erc20ContractAddress else {
                    return .just([])
                }
                return client
                    .ethereumERC20Activity(
                        from: key.address.publicKey,
                        contractAddress: contractAddress
                    )
                    .map(\.transfers)
                    .map { transfers -> [ERC20HistoricalTransaction] in
                        transfers.map { item in
                            ERC20HistoricalTransaction(
                                response: item,
                                cryptoCurrency: key.erc20Asset.cryptoCurrency!,
                                source: key.address
                            )
                        }
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func transactions(
        erc20Asset: AssetModel,
        address: EthereumAddress
    ) -> AnyPublisher<[ERC20HistoricalTransaction], NetworkError> {
        cachedValue.get(key: Key(erc20Asset: erc20Asset, address: address))
    }
}

extension ERC20HistoricalTransaction {

    init(
        response: ERC20TransfersResponse.Transfer,
        cryptoCurrency: CryptoCurrency,
        source: EthereumAddress
    ) {
        let createdAt: Date = Double(response.timestamp)
            .flatMap(Date.init(timeIntervalSince1970:)) ?? .distantPast
        let fromAddress = EthereumAddress(address: response.from, network: .ethereum)!
        let amount = CryptoValue.create(
            minor: response.value,
            currency: cryptoCurrency
        ) ?? .zero(currency: cryptoCurrency)

        self.init(
            fromAddress: fromAddress,
            toAddress: EthereumAddress(address: response.to, network: .ethereum)!,
            direction: fromAddress == source ? .credit : .debit,
            amount: amount,
            transactionHash: response.transactionHash,
            createdAt: createdAt,
            fee: nil,
            note: nil
        )
    }
}
