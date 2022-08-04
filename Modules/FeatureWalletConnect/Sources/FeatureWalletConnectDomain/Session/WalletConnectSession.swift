// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import WalletConnectSwift
import WalletPayloadKit

extension WalletConnectSession {
    init(session: Session) {
        let absoluteString = session.url.absoluteString
        let url = absoluteString.removingPercentEncoding ?? absoluteString
        let dAppInfo = DAppInfo(
            peerId: session.dAppInfo.peerId,
            peerMeta: ClientMeta(
                description: session.dAppInfo.peerMeta.description ?? "",
                url: session.dAppInfo.peerMeta.url.absoluteString,
                icons: session.dAppInfo.peerMeta.icons.map(\.absoluteString),
                name: session.dAppInfo.peerMeta.name
            ),
            chainId: session.walletInfo?.chainId ?? session.dAppInfo.chainId
        )
        let walletInfo = WalletInfo(
            clientId: session.walletInfo?.peerId ?? UUID().uuidString,
            sourcePlatform: "ios"
        )
        self.init(
            url: url,
            dAppInfo: dAppInfo,
            walletInfo: walletInfo
        )
    }
}

extension WalletConnectSession {
    /// Compares two WalletConnectSession based solely on its unique identifier (url).
    public func isEqual(_ rhs: Self) -> Bool {
        url == rhs.url
            || url.removingPercentEncoding == rhs.url.removingPercentEncoding
    }
}
