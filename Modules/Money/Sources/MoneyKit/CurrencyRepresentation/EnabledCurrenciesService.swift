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
        if polygonSupport.isEnabled {
            base.append(.polygon)
        }
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

    private var polygonERC20Currencies: [CryptoCurrency] {
        guard polygonSupport.isEnabled else {
            return []
        }
        return repository.polygonERC20Assets
            .currencies
            .filter { PolygonERC20CodeAllowList.allCases.map(\.rawValue).contains($0.code) }
            .filter(\.kind.isERC20)
            .compactMap(\.cryptoCurrency)
    }

    private lazy var allEnabledCryptoCurrenciesLazy: [CryptoCurrency] = (
        nonCustodialCryptoCurrencies
            + custodialCurrencies
            + ethereumERC20Currencies
            + polygonERC20Currencies
    )
    .unique
    .sorted()

    private lazy var allEnabledCurrenciesLazy: [CurrencyType] = allEnabledCryptoCurrencies.map(CurrencyType.crypto)
        + allEnabledFiatCurrencies.map(CurrencyType.fiat)

    private let allEnabledCryptoCurrenciesLock = NSLock()
    private let allEnabledCurrenciesLock = NSLock()

    private let polygonSupport: PolygonSupport
    private let repository: SupportedAssetsRepositoryAPI

    // MARK: Init

    init(
        polygonSupport: PolygonSupport,
        repository: SupportedAssetsRepositoryAPI
    ) {
        self.polygonSupport = polygonSupport
        self.repository = repository
    }
}

public protocol PolygonSupport: AnyObject {
    var isEnabled: Bool { get }
}
