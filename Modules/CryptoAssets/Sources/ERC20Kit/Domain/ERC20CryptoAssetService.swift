// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import EthereumKit
import MoneyKit
import PlatformKit

public enum ERC20CryptoAssetServiceError: LocalizedError, Equatable {
    case failedToLoadDefaultAccount
    case failedToLoadReceiveAddress
    case failedToFetchTokens

    public var errorDescription: String? {
        switch self {
        case .failedToLoadDefaultAccount:
            return "Failed to load default account."
        case .failedToLoadReceiveAddress:
            return "Failed to load receive address."
        case .failedToFetchTokens:
            return "Failed to load ERC20 Assets."
        }
    }
}

/// Service to initialise required ERC20 CryptoAsset.
public protocol ERC20CryptoAssetServiceAPI {
    func initialize() -> AnyPublisher<Void, ERC20CryptoAssetServiceError>
}

final class ERC20CryptoAssetService: ERC20CryptoAssetServiceAPI {

    private let accountsRepository: ERC20BalancesRepositoryAPI
    private let app: AppProtocol
    private let coincore: CoincoreAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    init(
        accountsRepository: ERC20BalancesRepositoryAPI,
        app: AppProtocol,
        coincore: CoincoreAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.accountsRepository = accountsRepository
        self.app = app
        self.coincore = coincore
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    func initialize() -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        var publishers: [AnyPublisher<Result<Void, ERC20CryptoAssetServiceError>, Never>] = EVMNetwork
            .allCases
            .map(initializeEVMNetwork)
            .map(\.resultPublisher)
        publishers.insert(initializeEthereum.resultPublisher, at: 0)
        return publishers
            .zip()
            .flatMap { results -> AnyPublisher<Void, ERC20CryptoAssetServiceError> in
                guard let error: ERC20CryptoAssetServiceError = results.map(\.failure).compacted().first else {
                    return .just(())
                }
                return .failure(error)
            }
            .eraseToAnyPublisher()
    }

    private var initializeEthereum: AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        Deferred { [coincore] in
            Just(coincore[.ethereum])
        }
        .flatMap(\.defaultAccount)
        .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadDefaultAccount)
        .flatMap { account in
            self.initialize(account: account, network: .ethereum)
        }
        .eraseToAnyPublisher()
    }

    private func initializeEVMNetwork(_ evmNetwork: EVMNetwork) -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        guard let tokensAlwaysFetchIsEnabled = evmNetwork.tokensAlwaysFetchIsEnabled else {
            return .just(())
        }
        guard enabledCurrenciesService.allEnabledCryptoCurrencies.contains(evmNetwork.cryptoCurrency) else {
            return .just(())
        }
        return Deferred { [coincore] in
            Just(coincore[evmNetwork.cryptoCurrency])
        }
        .flatMap(\.defaultAccount)
        .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadDefaultAccount)
        .flatMap { [app] account -> AnyPublisher<Void, ERC20CryptoAssetServiceError> in
            app
                .publisher(
                    for: tokensAlwaysFetchIsEnabled,
                    as: Bool.self
                )
                .first()
                .flatMap { alwaysFetch -> AnyPublisher<Bool, Error> in
                    alwaysFetch.value == true ? .just(true) : account.isFunded
                }
                .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadDefaultAccount)
                .flatMap { isFunded -> AnyPublisher<Void, ERC20CryptoAssetServiceError> in
                    guard isFunded else {
                        return .just(())
                    }
                    return self.initialize(account: account, network: evmNetwork)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func initialize(
        account: SingleAccount,
        network: EVMNetwork
    ) -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        account.receiveAddress
            .map { receiveAddress -> EthereumAddress? in
                EthereumAddress(address: receiveAddress.address)
            }
            .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadReceiveAddress)
            .onNil(ERC20CryptoAssetServiceError.failedToLoadReceiveAddress)
            .flatMap { [accountsRepository] ethereumAddress in
                accountsRepository.tokens(for: ethereumAddress, network: network)
                    .replaceError(with: ERC20CryptoAssetServiceError.failedToFetchTokens)
            }
            .handleEvents(
                receiveOutput: { [coincore] response -> Void in
                    // For each ERC20 token present in the response.
                    response.keys.forEach { currency in
                        // Gets its CryptoAsset from CoinCore to allow it to be preloaded.
                        _ = coincore[currency]
                    }
                }
            )
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

extension EVMNetwork {
    fileprivate var tokensAlwaysFetchIsEnabled: Tag.Event? {
        switch self {
        case .avalanceCChain:
            return blockchain.app.configuration.evm.avax.tokens.always.fetch.is.enabled
        case .binanceSmartChain:
            return blockchain.app.configuration.evm.bnb.tokens.always.fetch.is.enabled
        case .ethereum:
            return nil
        case .polygon:
            return blockchain.app.configuration.evm.polygon.tokens.always.fetch.is.enabled
        }
    }
}
