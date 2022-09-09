// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import MoneyKit
import RxSwift
import ToolKit

/// An `AccountGroup` containing all accounts.
public final class AllAccountsGroup: AccountGroup {
    private typealias LocalizedString = LocalizationConstants.AccountGroup

    public let accounts: [SingleAccount]
    public let identifier: AnyHashable = "AllAccountsGroup"
    public let label: String = LocalizedString.allWallets
    let actions: AvailableActions = [.viewActivity]

    public var accountType: AccountType = .group

    public var isFunded: AnyPublisher<Bool, Error> {
        guard !accounts.isEmpty else {
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
        guard !accounts.isEmpty else {
            return .failure(AccountGroupError.noAccounts)
        }
        return accounts
            .map(\.pendingBalance)
            .zip()
            .tryMap { [currencyType] values -> MoneyValue in
                try values.reduce(.zero(currency: currencyType), +)
            }
            .eraseToAnyPublisher()
    }

    public var balance: AnyPublisher<MoneyValue, Error> {
        guard !accounts.isEmpty else {
            return .failure(AccountGroupError.noAccounts)
        }
        return accounts
            .map(\.balance)
            .zip()
            .tryMap { [currencyType] values -> MoneyValue in
                try values.reduce(.zero(currency: currencyType), +)
            }
            .eraseToAnyPublisher()
    }

    public var actionableBalance: AnyPublisher<MoneyValue, Error> {
        guard !accounts.isEmpty else {
            return .failure(AccountGroupError.noAccounts)
        }
        return accounts
            .map(\.actionableBalance)
            .zip()
            .tryMap { [currencyType] values -> MoneyValue in
                try values.reduce(.zero(currency: currencyType), +)
            }
            .eraseToAnyPublisher()
    }

    public var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        .failure(ReceiveAddressError.notSupported)
    }

    public init(accounts: [SingleAccount]) {
        self.accounts = accounts
    }
}
