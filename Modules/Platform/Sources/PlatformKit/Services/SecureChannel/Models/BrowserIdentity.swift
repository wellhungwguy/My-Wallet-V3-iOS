// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct BrowserIdentity: Codable {
    /// The browser public key.
    let pubKey: String
    /// Timestamp (POSIX epoch in milliseconds) of when time browser identity was last used.
    var lastUsed: UInt64?
    /// Timestamp (POSIX epoch in milliseconds) of when this identity was created.
    let creation: UInt64
    /// Flag indicating if this identity was authorized by the user.
    var authorized: Bool

    var pubKeyHash: String {
        Data(hex: pubKey).sha256().hexValue
    }

    init(pubKey: String) {
        self.pubKey = pubKey
        self.lastUsed = nil
        self.creation = UInt64(Date().timeIntervalSince1970 * 1000)
        self.authorized = false
    }
}
