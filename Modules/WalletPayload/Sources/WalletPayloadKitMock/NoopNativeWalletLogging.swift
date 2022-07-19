import WalletPayloadKit

class NoopNativeWalletLogging: NativeWalletLoggerAPI {
    func log(message: String, metadata: [String: String]?) {}
}
