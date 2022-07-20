// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import MoneyKit
import RxSwift

/// An `AccountGroup` containing only Custodial accounts.
public class CryptoAccountCustodialGroup: AccountGroup {

    private typealias LocalizedString = LocalizationConstants.AccountGroup

    public let identifier: AnyHashable
    public let label: String
    public let accounts: [SingleAccount]

    public var accountType: AccountType = .group

    public var isFunded: AnyPublisher<Bool, Error> {
        account?.isFunded ?? .just(false)
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        account?.pendingBalance ?? .just(.zero(currency: asset))
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        account?.actionableBalance ?? .just(.zero(currency: asset))
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        account?.receiveAddress ?? .failure(ReceiveAddressError.notSupported)
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        account?.balance ?? .just(.zero(currency: asset))
    }

    private let asset: CryptoCurrency
    private var account: SingleAccount? {
        accounts.first
    }

    public var currencyType: CurrencyType {
        asset.currencyType
    }

    public convenience init(asset: CryptoCurrency, account: SingleAccount) {
        self.init(asset: asset, accounts: [account])
    }

    public convenience init(asset: CryptoCurrency) {
        self.init(asset: asset, accounts: [])
    }

    private init(
        asset: CryptoCurrency,
        accounts: [SingleAccount]
    ) {
        self.asset = asset
        label = String(format: LocalizedString.myCustodialWallets, asset.name)
        self.accounts = accounts
        if let account = accounts.first {
            identifier = "\(type(of: self)).\(type(of: account)).\(asset.code)"
        } else {
            identifier = "\(type(of: self)).Empty.\(asset.code)"
        }
    }
}
