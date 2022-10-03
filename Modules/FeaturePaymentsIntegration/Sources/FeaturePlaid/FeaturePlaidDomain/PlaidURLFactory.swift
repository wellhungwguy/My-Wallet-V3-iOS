// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum PlaidURLFactory {
    private static var baseUrl: URL {
        Bundle.main.plist.BLOCKCHAIN_WALLET_PAGE_LINK[]
            .flatMap(URL.https)
            .or(default: "https://blockchainwallet.page.link")
    }

    public static var linkTokenRedirectURI: String {
        baseUrl
            .appendingPathComponent("plaid")
            .absoluteString
    }

    public static func startPlaidUpdating(_ accountId: String) -> String? {
        var components = URLComponents()
        components.scheme = baseUrl.scheme

        if #available(iOS 16.0, *) {
            components.host = baseUrl.host()
        } else {
            components.host = baseUrl.host
        }
        components.path = "/start/plaid"

        components.queryItems = [
            URLQueryItem(name: "account_id", value: accountId)
        ]

        return components.string
    }
}
