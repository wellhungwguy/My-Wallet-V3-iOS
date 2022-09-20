// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Implementation of a EIP 681 URI Parser.
/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-681.md
struct EIP681URIParser {

    private enum SendQueryItem: String {
        /// Value of the transaction.
        case value
        /// Gas Limit: Same as `.gasLimit`.
        case gas
        /// Gas Limit: Same as `.gas`.
        case gasLimit
        /// Gas Price.
        case gasPrice
    }

    private enum TransferQueryItem: String {
        /// Transfer destination address.
        case address
        /// Value of the Transfer.
        case uint256
    }

    private static let scheme: String = "ethereum"
    private static let prefix: String = "\(scheme):"
    private static let regex = "^(pay-)?([0-9a-zA-Z.]+)(@[0-9]+)?\\/?(.*)?$"

    enum Method: Equatable {
        case send(amount: String?, gasLimit: String?, gasPrice: String?)
        case transfer(destination: String?, amount: String?)
    }

    let address: String
    let chainID: String?
    let method: Method

    init?(string: String) {
        guard string.hasPrefix(Self.prefix) else {
            return nil
        }
        let string = string.removing(prefix: Self.prefix)
        let matcher = try? NSRegularExpression(
            pattern: Self.regex,
            options: .dotMatchesLineSeparators
        )
        guard let matcher = matcher else {
            return nil
        }
        let nsRange = NSRange(
            string.startIndex..<string.endIndex,
            in: string
        )
        let matches = matcher.matches(
            in: string,
            options: .anchored,
            range: nsRange
        )
        // Should have only one Regex Match
        guard matches.count == 1 else {
            return nil
        }
        guard let match = matches.first else {
            return nil
        }
        // The match should have 5 ranges.
        guard match.numberOfRanges == 5 else {
            return nil
        }

        // Maps the match ranges into a HashMap, we know that each range represents a
        // different component from the EIP681 URI.
        // 0: main part (prefix + address)
        // 1: prefix (if present)
        // 2: address or ENS address
        // 3: chain ID (with @ prefix)
        // 4: query params
        let entries: [Int: String] = (0..<match.numberOfRanges)
            .compactMap { idx -> (Int, String)? in
                if let range = Range(match.range(at: idx), in: string) {
                    return (idx, String(string[range]))
                }
                return nil
            }
            .reduce(into: [Int: String]()) { partialResult, item in
                partialResult[item.0] = item.1
            }

        guard let address = entries[2] else {
            return nil
        }
        self.address = address
        chainID = entries[3]?.removing(prefix: "@")
        method = Self.method(for: entries[4])
    }

    /// Returns a `Method` for a given EIP681 query param.
    private static func method(for params: String?) -> Method {
        guard let params = params,
              !params.isEmpty,
              let components = URLComponents(string: params)
        else {
            return .send(amount: nil, gasLimit: nil, gasPrice: nil)
        }
        switch components.path {
        case "transfer":
            return buildTransfer(for: components)
        case "":
            return buildSend(for: components)
        default:
            return .send(amount: nil, gasLimit: nil, gasPrice: nil)
        }
    }

    /// Builds a `Method.send` from the given `URLComponents`.
    private static func buildSend(for components: URLComponents) -> Method {
        var amount: String?
        var gasLimit: String?
        var gasPrice: String?
        components.queryItems?
            .forEach { item in
                switch SendQueryItem(rawValue: item.name) {
                case .gasLimit, .gas:
                    gasLimit = item.value
                case .gasPrice:
                    gasPrice = item.value
                case .value:
                    amount = item.value
                case nil:
                    break
                }
            }
        return .send(amount: amount, gasLimit: gasLimit, gasPrice: gasPrice)
    }

    /// Builds a `Method.transfer` from the given `URLComponents`.
    private static func buildTransfer(for components: URLComponents) -> Method {
        var address: String?
        var amount: String?
        components.queryItems?
            .forEach { item in
                switch TransferQueryItem(rawValue: item.name) {
                case .address:
                    address = item.value
                case .uint256:
                    amount = item.value
                case nil:
                    break
                }
            }
        return .transfer(destination: address, amount: amount)
    }
}
