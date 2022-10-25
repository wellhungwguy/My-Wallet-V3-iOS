// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MoneyKit
import ToolKit

protocol AssetLoader {
    func initAndPreload() -> AnyPublisher<Void, Never>

    var loadedAssets: [CryptoAsset] { get }

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset { get }
}

/// An AssetLoader that loads some CryptoAssets straight away, and lazy load others.
final class DynamicAssetLoader: AssetLoader {

    // MARK: Properties

    var loadedAssets: [CryptoAsset] {
        storage.value
            .sorted { lhs, rhs in
                lhs.key < rhs.key
            }
            .map(\.value)
    }

    // MARK: Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let evmAssetFactory: EVMAssetFactoryAPI
    private let erc20AssetFactory: ERC20AssetFactoryAPI
    private let storage: Atomic<[CryptoCurrency: CryptoAsset]> = Atomic([:])
    private let evmNetworksStorage: Atomic<[String: EVMNetwork]> = Atomic([:])

    // MARK: Init

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        evmAssetFactory: EVMAssetFactoryAPI,
        erc20AssetFactory: ERC20AssetFactoryAPI
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.evmAssetFactory = evmAssetFactory
        self.erc20AssetFactory = erc20AssetFactory
    }

    // MARK: Methods

    /// Pre loads into Coincore (in memory) all Coin non-custodial assets and any other asset that has Custodial support.
    func initAndPreload() -> AnyPublisher<Void, Never> {
        Deferred { [storage, enabledCurrenciesService, evmAssetFactory, erc20AssetFactory, evmNetworksStorage] in
            Future<Void, Never> { subscriber in
                let allEnabledCryptoCurrencies = enabledCurrenciesService.allEnabledCryptoCurrencies
                let allEnabledEVMNetworks = enabledCurrenciesService.allEnabledEVMNetworks

                let nonCustodialCoinCodes = NonCustodialCoinCode.allCases
                    .filter { $0 != .ethereum }
                    .map(\.rawValue)

                // Crypto Assets for coins with Non Custodial support (BTC, BCH, ETH, XLM)
                let nonCustodialAssets: [CryptoAsset] = allEnabledCryptoCurrencies
                    .filter(\.isCoin)
                    .filter { nonCustodialCoinCodes.contains($0.code) }
                    .map { cryptoCurrency -> CryptoAsset in
                        DIKit.resolve(tag: cryptoCurrency)
                    }

                // Compute EVMs
                let evmNetworksHashMap = allEnabledEVMNetworks.reduce(into: [:]) { partialResult, network in
                    partialResult[network.networkConfig.networkTicker] = network
                }
                evmNetworksStorage.mutate {
                    $0 = evmNetworksHashMap
                }

                // Load EVM CryptoAsset

                let evmAssets: [CryptoAsset] = allEnabledEVMNetworks.map(evmAssetFactory.evmAsset(network:))

                // Crypto Currencies with Custodial support.
                let filterOutCodes: [String] = nonCustodialCoinCodes + evmNetworksHashMap.keys
                let custodialCryptoCurrencies: [CryptoCurrency] = allEnabledCryptoCurrencies
                    .filter { cryptoCurrency in
                        cryptoCurrency.supports(product: .custodialWalletBalance)
                    }
                    .filter { cryptoCurrency in
                        !filterOutCodes.contains(cryptoCurrency.code)
                    }

                // Crypto Assets for any currency with Custodial support.
                let custodialAssets: [CryptoAsset] = custodialCryptoCurrencies
                    .compactMap { [erc20AssetFactory] cryptoCurrency -> CryptoAsset? in
                        createCryptoAsset(
                            cryptoCurrency: cryptoCurrency,
                            erc20AssetFactory: erc20AssetFactory,
                            evmNetworks: evmNetworksHashMap
                        )
                    }

                storage.mutate { storage in
                    storage.removeAll()
                    nonCustodialAssets.forEach { asset in
                        storage[asset.asset] = asset
                    }
                    evmAssets.forEach { asset in
                        storage[asset.asset] = asset
                    }
                    custodialAssets.forEach { asset in
                        storage[asset.asset] = asset
                    }
                }
                subscriber(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Subscript

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
        let evmNetworksHashMap = evmNetworksStorage.value
        return storage.mutateAndReturn { [erc20AssetFactory] storage in
            guard let cryptoAsset = storage[cryptoCurrency] else {
                let cryptoAsset: CryptoAsset = createCryptoAsset(
                    cryptoCurrency: cryptoCurrency,
                    erc20AssetFactory: erc20AssetFactory,
                    evmNetworks: evmNetworksHashMap
                )
                storage[cryptoCurrency] = cryptoAsset
                return cryptoAsset
            }
            return cryptoAsset
        }
    }
}

private func createCryptoAsset(
    cryptoCurrency: CryptoCurrency,
    erc20AssetFactory: ERC20AssetFactoryAPI,
    evmNetworks: [String: EVMNetwork]
) -> CryptoAsset {
    switch cryptoCurrency.assetModel.kind {
    case .coin, .celoToken:
        return CustodialCryptoAsset(asset: cryptoCurrency)
    case .erc20(_, let parentChain):
        guard let network = evmNetworks[parentChain] else {
            impossible()
        }
        return erc20AssetFactory.erc20Asset(network: network, erc20Token: cryptoCurrency.assetModel)
    case .fiat:
        impossible()
    }
}
