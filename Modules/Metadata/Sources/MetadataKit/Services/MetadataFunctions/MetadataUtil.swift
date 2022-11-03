// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum MetadataUtil {

    static func deriveHardened(
        node: PrivateKey,
        type: UInt32
    ) -> PrivateKey {
        node.derive(at: .hardened(type))
    }

    static func magic(
        payload: [UInt8],
        prevMagicHash: [UInt8]?
    ) -> Result<[UInt8], Error> {
        message(payload: payload, prevMagicHash: prevMagicHash)
            .flatMap { msg -> Result<[UInt8], Error> in
                magicHash(message: msg)
            }
    }

    private static func magicHash(
        message: [UInt8]
    ) -> Result<[UInt8], Error> {
        let messageBase64String = Data(message).base64EncodedString()
        return PrivateKey.formatBTCMessageForSigning(message: messageBase64String)
            .map(Data.init(_:))
            .map(\.doubleSHA256)
            .map(\.bytes)
    }

    static func message(
        payload: [UInt8],
        prevMagicHash: [UInt8]? = nil
    ) -> Result<[UInt8], Error> {
        guard let prevMagicHash else {
            return .success(payload)
        }
        let payloadHash = payload.sha256()
        let output = prevMagicHash + payloadHash
        return .success(output)
    }
}
