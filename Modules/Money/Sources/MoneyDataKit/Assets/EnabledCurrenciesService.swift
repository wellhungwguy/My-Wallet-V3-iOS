// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyDomainKit

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    // MARK: EnabledCurrenciesServiceAPI

    let allEnabledFiatCurrencies: [FiatCurrency] = FiatCurrency.allEnabledFiatCurrencies

    let bankTransferEligibleFiatCurrencies: [FiatCurrency] = [.USD, .ARS]

    var allEnabledCurrencies: [CurrencyType] {
        defer { allEnabledCurrenciesLock.unlock() }
        allEnabledCurrenciesLock.lock()
        return allEnabledCurrenciesLazy
    }

    var allEnabledCryptoCurrencies: [CryptoCurrency] {
        defer { allEnabledCryptoCurrenciesLock.unlock() }
        allEnabledCryptoCurrenciesLock.lock()
        return allEnabledCryptoCurrenciesLazy
    }

    // MARK: Private Properties

    private var nonCustodialCryptoCurrencies: [CryptoCurrency] {
        var base: [CryptoCurrency] = [
            .bitcoin,
            .ethereum,
            .bitcoinCash,
            .stellar
        ]

        let evms: [CryptoCurrency] = AssetModelType
            .ERC20ParentChain
            .allCases
            .filter { $0 != .ethereum }
            .filter { evmSupport.isEnabled(network: $0) }
            .map(\.cryptoCurrency)
            .sorted()

        base.append(contentsOf: evms)

        return base
    }

    private var custodialCurrencies: [CryptoCurrency] {
        repository.custodialAssets
            .currencies
            .filter(\.products.enablesCurrency)
            .filter { !NonCustodialCoinCode.allCases.map(\.rawValue).contains($0.code) }
            .compactMap(\.cryptoCurrency)
    }

    private var ethereumERC20Currencies: [CryptoCurrency] {
        repository.ethereumERC20Assets
            .currencies
            .filter(\.kind.isERC20)
            .compactMap(\.cryptoCurrency)
    }

    private var otherERC20Currencies: [CryptoCurrency] {
        repository.otherERC20Assets
            .currencies
            .filter(\.kind.isERC20)
            .filter { model in
                model.kind.erc20ParentChain
                    .flatMap(evmSupport.isEnabled(network:)) ?? false
            }
            .compactMap(\.cryptoCurrency)
    }

    private lazy var allEnabledCryptoCurrenciesLazy: [CryptoCurrency] = (
        nonCustodialCryptoCurrencies
            + custodialCurrencies
            + ethereumERC20Currencies
            + otherERC20Currencies
    )
    .unique
    .sorted()

    private lazy var allEnabledCurrenciesLazy: [CurrencyType] = allEnabledCryptoCurrencies.map(CurrencyType.crypto)
        + allEnabledFiatCurrencies.map(CurrencyType.fiat)

    private let allEnabledCryptoCurrenciesLock = NSLock()
    private let allEnabledCurrenciesLock = NSLock()

    private let evmSupport: EVMSupportAPI
    private let repository: SupportedAssetsRepositoryAPI

    // MARK: Init

    init(
        evmSupport: EVMSupportAPI,
        repository: SupportedAssetsRepositoryAPI
    ) {
        self.evmSupport = evmSupport
        self.repository = repository
    }
}

extension AssetModelType.ERC20ParentChain {
    fileprivate var cryptoCurrency: CryptoCurrency {
        switch self {
        case .avax:
            return .avax
        case .bnb:
            return .bnb
        case .ethereum:
            return .ethereum
        case .polygon:
            return .polygon
        }
    }
}

extension [AssetModelProduct] {

    /// Whether the list of supported products causes its owner currency to be enabled in the wallet app.
    var enablesCurrency: Bool {
        contains { product in
            product.enablesCurrency
        }
    }
}

extension AssetModelProduct {

    /// Whether the current `AssetModelProduct` causes its owner currency to be enabled in the wallet app.
    fileprivate var enablesCurrency: Bool {
        switch self {
        case .custodialWalletBalance:
            return true
        default:
            return false
        }
    }
}
