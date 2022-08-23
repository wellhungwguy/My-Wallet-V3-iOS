// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import RxSwift
import StellarKit
import ToolKit

/// `StellarWalletBridgeAPI` is part of the `bridge` that is used when injecting the `wallet` into
/// a `WalletAccountRepository`. This is how we save the users `StellarKeyPair`
final class StellarWallet: StellarWalletBridgeAPI {

    private let wallet: Wallet

    init(walletManager: WalletManager = resolve()) {
        wallet = walletManager.wallet
    }

    func update(accountIndex: Int, label: String) -> Completable {
        wallet.updateAccountLabel(.stellar, index: accountIndex, label: label)
    }

    func save(keyPair: StellarKit.StellarKeyPair, label: String, completion: @escaping (Result<Void, Error>) -> Void) {
        wallet.saveXlmAccount(
            keyPair.accountID,
            label: label,
            success: {
                completion(.success(()))
            },
            error: { error in
                Logger.shared.error(error)
                completion(.failure(StellarAccountError.unableToSaveNewAccount))
            }
        )
    }

    func stellarWallets() -> [StellarKit.StellarWalletAccount] {
        guard let xlmAccountsRaw = wallet.getXlmAccounts() else {
            return []
        }
        guard !xlmAccountsRaw.isEmpty else {
            return []
        }
        return xlmAccountsRaw.castJsonObjects(type: StellarWalletAccount.self)
    }
}
