//  Copyright © 2022 Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
import PulseCore
#endif

import WalletPayloadKit

/// This is intentionally on main target as it uses `Pulse` to log messages.
final class NativeWalletLogger: NativeWalletLoggerAPI {

    func log(message: String, metadata: [String: String]?) {
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        LoggerStore.default.storeMessage(
            label: "wallet.native",
            level: .debug,
            message: message,
            metadata: metadata?
                .mapKeysAndValues(
                    key: { $0 },
                    value: { LoggerStore.MetadataValue.string($0) }
                )
        )
        #endif
    }
}
