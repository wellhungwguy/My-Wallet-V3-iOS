// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public struct BitPayClientEngineTransaction {
    let encodedMsg: String
    let msgSize: Int
    let txHash: String

    public init(encodedMsg: String, msgSize: Int, txHash: String) {
        self.encodedMsg = encodedMsg
        self.msgSize = msgSize
        self.txHash = txHash
    }
}

public protocol BitPayClientEngine {
    /// Prepares and signs a `PendingTransaction` so it can be sent to BitPay.
    func doPrepareBitPayTransaction(
        pendingTransaction: PendingTransaction
    ) -> Single<BitPayClientEngineTransaction>

    /// Called after a BitPay transaction is successfully executed.
    func doOnBitPayTransactionSuccess(
        pendingTransaction: PendingTransaction
    )

    /// Called after a BitPay transaction is unsuccessfully executed.
    func doOnBitPayTransactionFailed(
        pendingTransaction: PendingTransaction,
        error: Error
    )
}
