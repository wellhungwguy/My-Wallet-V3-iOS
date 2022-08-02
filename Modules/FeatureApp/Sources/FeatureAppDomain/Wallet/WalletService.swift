// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct WalletService {
    public var fetch: (
        _ password: String
    ) -> AnyPublisher<WalletFetchedContext, WalletError>

    public var recoverFromMetadata: (
        _ mnemonic: String
    ) -> AnyPublisher<WalletFetchedContext, WalletError>
}

extension WalletService {
    public static func live(
        fetcher: WalletFetcherAPI,
        recovery: WalletRecoveryServiceAPI
    ) -> WalletService {
        WalletService(
            fetch: { password -> AnyPublisher<WalletFetchedContext, WalletError> in
                fetcher.fetch(using: password)
            },
            recoverFromMetadata: { mnemonic -> AnyPublisher<WalletFetchedContext, WalletError> in
                recovery.recover(from: mnemonic)
            }
        )
    }
}
