// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MetadataKit
import ToolKit

public enum TxNotesServiceProvider {

    public static func provideWalletTxNoteStrategy() -> TxNoteUpdateProvideStrategyAPI {
        let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
        let queue = DispatchQueue(
            label: "wallet.txnote.service.op.queue",
            qos: .userInitiated,
            target: targetQueue
        )
        return WalletTxNoteStrategy(
            walletHolder: DIKit.resolve(),
            walletRepo: DIKit.resolve(),
            walletSync: DIKit.resolve(),
            operationQueue: queue
        )
    }
}
