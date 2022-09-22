// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCurrencies: [CurrencyType] { get }
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    /// This returns the supported currencies that a user can link a bank through a partner, eg Yodlee
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { get }
}

public let allEnabledFiatCurrencies: [FiatCurrency] = [.USD, .EUR, .GBP, .ARS]

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    // MARK: EnabledCurrenciesServiceAPI

    let allEnabledFiatCurrencies: [FiatCurrency] = MoneyKit.allEnabledFiatCurrencies

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

    private let evmSupport: EVMSupport
    private let repository: SupportedAssetsRepositoryAPI

    // MARK: Init

    init(
        evmSupport: EVMSupport,
        repository: SupportedAssetsRepositoryAPI
    ) {
        self.evmSupport = evmSupport
        self.repository = repository
    }
}

public protocol EVMSupport: AnyObject {

    var sanitizeTokenNamesEnabled: Bool { get }

    func isEnabled(network: AssetModelType.ERC20ParentChain) -> Bool
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
