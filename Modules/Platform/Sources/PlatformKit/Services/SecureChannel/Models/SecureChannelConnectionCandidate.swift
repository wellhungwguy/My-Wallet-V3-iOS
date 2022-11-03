// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct SecureChannelConnectionCandidate {
    public let details: SecureChannelConnectionDetails
    /// Flag indicating if the connection candidate was previously approved
    public let isAuthorized: Bool
    /// Date of when the request to connect was received.
    public let timestamp: Date
    /// Date of when this connection candidate was last used.
    public let lastUsed: Date?

    /// Default initialiser.
    /// - Parameter details: `SecureChannelConnectionDetails` object.
    /// - Parameter isAuthorized: Flag indicating if the connection candidate was previously approved.
    /// - Parameter timestamp: `UInt64` timestamp (POSIX epoch in milliseconds) of when the request to connect was received.
    /// - Parameter lastUsed: `UInt64` timestamp (POSIX epoch in milliseconds) of when the connection candidate was last used.
    init(details: SecureChannelConnectionDetails, isAuthorized: Bool, timestamp: UInt64, lastUsed: UInt64?) {
        self.details = details
        self.isAuthorized = isAuthorized
        self.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        if let lastUsed {
            self.lastUsed = Date(timeIntervalSince1970: TimeInterval(lastUsed) / 1000)
        } else {
            self.lastUsed = nil
        }
    }
}
