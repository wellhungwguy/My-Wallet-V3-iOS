// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import NetworkKit
import PlatformKit

public protocol TransactionDetailServiceAPI {

    /// Returns the URL for the specified address's transaction detail.
    ///
    /// - Parameter transactionHash: the hash of the transaction
    /// - Parameter cryptoCurrency: the `CryptoCurrency`
    /// - Returns: the URL for the transaction detail
    func transactionDetailURL(for transactionHash: String, cryptoCurrency: CryptoCurrency) -> String?
}

final class TransactionDetailService: TransactionDetailServiceAPI {

    private let blockchainAPI: BlockchainAPI

    init(blockchainAPI: BlockchainAPI) {
        self.blockchainAPI = blockchainAPI
    }

    func transactionDetailURL(for transactionHash: String, cryptoCurrency: CryptoCurrency) -> String? {
        switch (cryptoCurrency.assetModel, cryptoCurrency.assetModel.kind) {
        case (.bitcoin, _):
            return "\(blockchainAPI.bitcoinExplorerUrl)/tx/\(transactionHash)"
        case (.ethereum, _):
            return "\(blockchainAPI.etherExplorerUrl)/tx/\(transactionHash)"
        case (.bitcoinCash, _):
            return "\(blockchainAPI.bitcoinCashExplorerUrl)/tx/\(transactionHash)"
        case (.stellar, _):
            return "\(blockchainAPI.stellarchainUrl)/tx/\(transactionHash)"
        case (_, .erc20):
            return "\(blockchainAPI.etherExplorerUrl)/tx/\(transactionHash)"
        default:
            return nil
        }
    }
}
