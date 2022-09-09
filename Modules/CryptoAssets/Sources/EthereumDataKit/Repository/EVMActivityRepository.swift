// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import PlatformKit
import ToolKit

final class EVMActivityRepository: EVMActivityRepositoryAPI {

    private struct Key: Hashable {
        let cryptoCurrency: CryptoCurrency
        let address: String
    }

    private let client: EVMActivityClientAPI
    private let latestBlockRepository: LatestBlockRepositoryAPI
    private let cachedValue: CachedValueNew<
        Key,
        [EVMHistoricalTransaction],
        Error
    >

    init(
        client: EVMActivityClientAPI,
        latestBlockRepository: LatestBlockRepositoryAPI
    ) {
        self.client = client
        self.latestBlockRepository = latestBlockRepository
        let cache: AnyCache<Key, [EVMHistoricalTransaction]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client, latestBlockRepository] key in
                let cryptoCurrency = key.cryptoCurrency
                guard let network = cryptoCurrency.assetModel.evmNetwork else {
                    return .just([])
                }
                let contractAddress = cryptoCurrency.assetModel
                    .kind
                    .erc20ContractAddress

                let activity = client
                    .evmActivity(
                        address: key.address,
                        contractAddress: contractAddress,
                        network: network
                    )
                    .eraseError()
                let currentBlock = latestBlockRepository
                    .latestBlock(network: network)
                    .eraseError()

                return activity.zip(currentBlock)
                    .map { response, currentBlock -> [EVMHistoricalTransaction] in
                        response
                            .history
                            .compactMap { item in
                                EVMHistoricalTransaction(
                                    network: network,
                                    response: item,
                                    cryptoCurrency: cryptoCurrency,
                                    contractAddress: contractAddress,
                                    source: key.address,
                                    currentBlock: currentBlock
                                )
                            }
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func transactions(
        cryptoCurrency: CryptoCurrency,
        address: String
    ) -> AnyPublisher<[EVMHistoricalTransaction], Error> {
        cachedValue.get(
            key: Key(
                cryptoCurrency: cryptoCurrency,
                address: address.lowercased()
            )
        )
    }
}

extension EVMHistoricalTransaction {

    init?(
        network: EVMNetwork,
        response: EVMTransactionHistoryResponse.Item,
        cryptoCurrency: CryptoCurrency,
        contractAddress: String?,
        source: String,
        currentBlock: BigInt
    ) {
        let requiredConfirmations = 12
        let confirmations = response.extraData
            .blockNumber
            .flatMap(BigInt.init)
            .flatMap { currentBlock - $0 }
            .flatMap { max(0, $0) } ?? 0

        let confirmation = Confirmation(
            needConfirmation: response.status == .pending,
            confirmations: Int(confirmations),
            requiredConfirmations: requiredConfirmations,
            factor: Float(confirmations) / Float(requiredConfirmations),
            status: response.status == .completed ? .confirmed : .pending
        )
        let contractAddress = contractAddress ?? "native"
        let filtered = response.movements
            .filter { $0.identifier.caseInsensitiveCompare(contractAddress) == .orderedSame }
        guard !filtered.isEmpty else {
            return nil
        }
        guard let sent = filtered.first(where: { $0.type == "SENT" }) else {
            Self.crashIfDebug("No SENT movement.")
            return nil
        }
        guard let received = filtered.first(where: { $0.type == "RECEIVED" }) else {
            Self.crashIfDebug("No RECEIVED movement.")
            return nil
        }
        guard let fromAddress = EthereumAddress(address: sent.address) else {
            Self.crashIfDebug("SENT movement address invalid \(sent.address).")
            return nil
        }
        guard let toAddress = EthereumAddress(address: received.address) else {
            Self.crashIfDebug("RECEIVED movement address invalid \(received.address).")
            return nil
        }
        let amount = CryptoValue.create(minor: sent.amount, currency: cryptoCurrency)
        if amount == nil {
            Self.crashIfDebug("SENT movement amount invalid \(sent.amount).")
        }

        let fee = CryptoValue.create(
            minor: response.fee,
            currency: network.cryptoCurrency
        ) ?? .zero(currency: network.cryptoCurrency)

        let direction: EthereumDirection
        if fromAddress == toAddress {
            direction = .transfer
        } else if toAddress == EthereumAddress(address: source)! {
            direction = .receive
        } else {
            direction = .send
        }
        self.init(
            amount: amount ?? .zero(currency: cryptoCurrency),
            confirmation: confirmation,
            createdAt: Date(timeIntervalSince1970: response.timestamp),
            direction: direction,
            fee: fee,
            from: fromAddress,
            identifier: response.txId,
            to: toAddress
        )
    }

    private static func crashIfDebug(_ message: String) {
        if BuildFlag.isInternal {
            fatalError(message)
        }
    }
}
