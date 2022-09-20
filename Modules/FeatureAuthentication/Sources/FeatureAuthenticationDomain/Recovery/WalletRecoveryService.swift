// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import WalletPayloadKit

public struct WalletRecoveryService {
    public var recoverFromMetadata: (
        _ mnemonic: String
    ) -> AnyPublisher<Either<EmptyValue, WalletFetchedContext>, WalletError>
}

extension WalletRecoveryService {
    public static func live(walletRecovery: WalletRecoveryServiceAPI) -> Self {
        Self(
            recoverFromMetadata: { [walletRecovery] mnemonic in
                walletRecovery.recover(from: mnemonic)
                    .map { value in .right(value) }
                    .eraseToAnyPublisher()
            }
        )
    }

    public static var noop: Self {
        Self(recoverFromMetadata: { _ in .empty() })
    }
}
