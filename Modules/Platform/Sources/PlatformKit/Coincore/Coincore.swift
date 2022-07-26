// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import RxSwift
import ToolKit
import WalletPayloadKit

public enum CoincoreError: Error, Equatable {
    case failedToInitializeAsset(error: AssetError)
}

/// Types adopting the `CoincoreAPI` should provide a way to retrieve fiat and crypto accounts
public protocol CoincoreAPI {

    /// Provides access to fiat and crypto custodial and non custodial assets.
    var allAccounts: AnyPublisher<AccountGroup, CoincoreError> { get }

    var allAssets: [Asset] { get }
    var fiatAsset: Asset { get }
    var cryptoAssets: [CryptoAsset] { get }

    /// Initialize any assets prior being available
    func initialize() -> AnyPublisher<Void, CoincoreError>

    /// Provides an array of `SingleAccount` instances for the specified source account and the given action.
    /// - Parameters:
    ///   - sourceAccount: A `BlockchainAccount` to be used as the source account
    ///   - action: An `AssetAction` to determine the transaction targets.
    func getTransactionTargets(
        sourceAccount: BlockchainAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], CoincoreError>

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset { get }
}

final class Coincore: CoincoreAPI {

    // MARK: - Public Properties

    var allAccounts: AnyPublisher<AccountGroup, CoincoreError> {
        reactiveWallet.waitUntilInitializedFirst
            .flatMap { [allAssets] _ -> AnyPublisher<[AccountGroup], Never> in
                allAssets
                    .map { asset in
                        asset.accountGroup(filter: .all)
                    }
                    .zip()
            }
            .map { accountGroups -> [SingleAccount] in
                accountGroups
                    .map(\.accounts)
                    .reduce(into: [SingleAccount]()) { result, accounts in
                        result.append(contentsOf: accounts)
                    }
            }
            .map { accounts -> AccountGroup in
                AllAccountsGroup(accounts: accounts)
            }
            .eraseToAnyPublisher()
            .mapError()
    }

    let fiatAsset: Asset
    var allAssets: [Asset] {
        [fiatAsset] + cryptoAssets
    }

    var cryptoAssets: [CryptoAsset] {
        assetLoader.loadedAssets
    }

    // MARK: - Private Properties

    private let assetLoader: AssetLoader
    private let reactiveWallet: ReactiveWalletAPI

    private let queue: DispatchQueue

    // MARK: - Setup

    init(
        assetLoader: AssetLoader,
        fiatAsset: FiatAsset,
        reactiveWallet: ReactiveWalletAPI,
        queue: DispatchQueue
    ) {
        self.assetLoader = assetLoader
        self.fiatAsset = fiatAsset
        self.reactiveWallet = reactiveWallet
        self.queue = queue
    }

    /// Gives a chance for all assets to initialize themselves.
    func initialize() -> AnyPublisher<Void, CoincoreError> {
        assetLoader
            .initAndPreload()
            .subscribe(on: queue)
            .receive(on: queue)
            .mapError(to: CoincoreError.self)
            .flatMap { [assetLoader] _ -> AnyPublisher<Void, CoincoreError> in
                assetLoader.loadedAssets
                    .map { asset -> AnyPublisher<Void, CoincoreError> in
                        asset.initialize()
                            .mapError { error in
                                .failedToInitializeAsset(error: error)
                            }
                            .eraseToAnyPublisher()
                    }
                    .zip()
                    .mapToVoid()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
        assetLoader[cryptoCurrency]
    }

    /// We are looking for targets of our action.
    /// Action is considered what the source account wants to do.
    func getTransactionTargets(
        sourceAccount: BlockchainAccount,
        action: AssetAction
    ) -> AnyPublisher<[SingleAccount], CoincoreError> {
        switch action {
        case .swap,
             .interestTransfer,
             .interestWithdraw:
            guard let cryptoAccount = sourceAccount as? CryptoAccount else {
                fatalError("Expected CryptoAccount: \(sourceAccount)")
            }
            return allAccounts
                .map(\.accounts)
                .map { accounts -> [SingleAccount] in
                    accounts.filter { destinationAccount -> Bool in
                        Self.getActionFilter(
                            sourceAccount: cryptoAccount,
                            destinationAccount: destinationAccount,
                            action: action
                        )
                    }
                }
                .eraseToAnyPublisher()
        case .send:
            guard let cryptoAccount = sourceAccount as? CryptoAccount else {
                fatalError("Expected CryptoAccount: \(sourceAccount)")
            }
            return self[cryptoAccount.asset]
                .transactionTargets(account: cryptoAccount)
                .map { accounts -> [SingleAccount] in
                    accounts.filter { destinationAccount -> Bool in
                        Self.getActionFilter(
                            sourceAccount: cryptoAccount,
                            destinationAccount: destinationAccount,
                            action: action
                        )
                    }
                }
                .mapError()
        case .buy:
            unimplemented("WIP")
        case .deposit,
             .receive,
             .sell,
             .sign,
             .viewActivity,
             .withdraw,
             .linkToDebitCard:
            unimplemented("\(action) is not supported.")
        }
    }

    private static func getActionFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        switch action {
        case .buy:
            unimplemented("WIP")
        case .interestTransfer:
            return interestTransferFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .interestWithdraw:
            return interestWithdrawFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .sell:
            return destinationAccount is FiatAccount
        case .swap:
            return swapActionFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .send:
            return sendActionFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .deposit,
             .receive,
             .sign,
             .viewActivity,
             .withdraw,
             .linkToDebitCard:
            return false
        }
    }

    private static func interestTransferFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else {
            return false
        }
        switch (sourceAccount, destinationAccount) {
        case (is CryptoTradingAccount, is CryptoInterestAccount),
             (is CryptoNonCustodialAccount, is CryptoInterestAccount):
            return true
        default:
            return false
        }
    }

    private static func interestWithdrawFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else {
            return false
        }
        switch (sourceAccount, destinationAccount) {
        case (is CryptoInterestAccount, is CryptoTradingAccount),
             (is CryptoInterestAccount, is CryptoNonCustodialAccount):
            return true
        default:
            return false
        }
    }

    private static func swapActionFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType != sourceAccount.currencyType else {
            return false
        }
        switch (sourceAccount, destinationAccount) {
        case (is CryptoTradingAccount, is CryptoTradingAccount),
             (is CryptoNonCustodialAccount, is CryptoTradingAccount),
             (is CryptoNonCustodialAccount, is CryptoNonCustodialAccount):
            return true
        default:
            return false
        }
    }

    private static func sendActionFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else {
            return false
        }
        switch destinationAccount {
        case is CryptoTradingAccount,
             is CryptoExchangeAccount,
             is CryptoNonCustodialAccount:
            return true
        default:
            return false
        }
    }
}
