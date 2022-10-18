// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit
import PlatformKit

/// A URI scheme that conforms to BIP21 (https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki)
public struct BIP21URI<Token: BitcoinChainToken> {

    public let address: String
    public let amount: CryptoValue?
    public var absoluteString: String {
        let prefix = includeScheme ? "\(Token.coin.uriScheme):" : ""
        return "\(prefix)\(address)"
    }

    private let includeScheme: Bool

    init(address: String, amount: String?, includeScheme: Bool) {
        self.address = address
        self.amount = amount.flatMap { .create(major: $0, currency: Token.coin.cryptoCurrency) }
        self.includeScheme = includeScheme
    }

    public init?(url: URL) {
        // Checks if scheme matches the Token scheme (scheme is required).
        guard url.scheme == Token.coin.uriScheme else {
            return nil
        }

        let address: String?
        let amount: String?
        let urlString = url.absoluteString
        let doubleSlash = "//"
        let colon = ":"
        let bitpayPaymentLink = "https://bitpay.com/"
        let hasBitpayPaymentUrl = urlString.contains(bitpayPaymentLink)

        if urlString.contains(doubleSlash), !hasBitpayPaymentUrl {
            let queryArgs = url.queryArgs

            address = url.host ?? queryArgs["address"]
            amount = queryArgs["amount"]
        } else if urlString.contains(colon), hasBitpayPaymentUrl {
            return nil
        } else if urlString.contains(colon) {
            // Handle web format (e.g. "scheme:1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
            guard let request = urlString.components(separatedBy: colon).last else {
                return nil
            }
            let requestComponents = request.components(separatedBy: "?")
            if let args = requestComponents.last {
                let queryArgs = args.queryArgs
                address = requestComponents.first ?? queryArgs["address"]
                amount = queryArgs["amount"]
            } else {
                address = requestComponents.first
                amount = nil
            }
        } else {
            address = nil
            amount = nil
        }

        guard let address else {
            return nil
        }

        self.init(address: address, amount: amount, includeScheme: true)
    }
}
