// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import MoneyKit
import RxSwift

/// An `AccountGroup` containing only Non Custodial accounts.
public class CryptoAccountNonCustodialGroup: AccountGroup {

    private typealias LocalizedString = LocalizationConstants.AccountGroup

    private let asset: CryptoCurrency

    public private(set) lazy var identifier: AnyHashable = "CryptoAccountNonCustodialGroup." + asset.code

    public let label: String

    public let accounts: [SingleAccount]

    public var accountType: AccountType = .group

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        if accounts.isEmpty {
            return .just(.zero(currency: asset))
        }
        return accounts
            .map(\.actionableBalance)
            .zip()
            .tryMap { [asset] values -> MoneyValue in
                try values.reduce(.zero(currency: asset), +)
            }
            .eraseToAnyPublisher()
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(AccountGroupError.noReceiveAddress)
    }

    public var isFunded: AnyPublisher<Bool, Error> {
        if accounts.isEmpty {
            return .just(false)
        }
        return accounts
            .map(\.isFunded)
            .zip()
            .map { values -> Bool in
                values.contains(true)
            }
            .eraseToAnyPublisher()
    }

    public var pendingBalance: AnyPublisher<MoneyValue, Error> {
        if accounts.isEmpty {
            return .just(.zero(currency: asset))
        }
        return accounts
            .map(\.pendingBalance)
            .zip()
            .tryMap { [asset] values -> MoneyValue in
                try values.reduce(.zero(currency: asset), +)
            }
            .eraseToAnyPublisher()
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        if accounts.isEmpty {
            return .just(.zero(currency: asset))
        }
        return accounts
            .map(\.balance)
            .zip()
            .tryMap { [asset] values -> MoneyValue in
                try values.reduce(.zero(currency: asset), +)
            }
            .eraseToAnyPublisher()
    }

    public init(asset: CryptoCurrency, accounts: [SingleAccount]) {
        self.asset = asset
        label = String(format: LocalizedString.myWallets, asset.name)
        self.accounts = accounts
    }
}
