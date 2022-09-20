// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public typealias JSONDictionary = [String: Any]

public struct WalletOptions: Decodable {

    enum CodingKeys: String, CodingKey {
        case domains
        case exchangeAddresses
        case hotWalletAddresses
        case xlm
        case xlmExchange
    }

    public struct Domains: Decodable {
        public let stellarHorizon: String?
    }

    public struct XLMMetadata: Decodable {
        public let sendTimeOutSeconds: Int
    }

    // MARK: - Properties

    public let domains: Domains?
    public let hotWalletAddresses: [String: [String: String]]?
    public let xlmExchangeAddresses: [String]?
    public let xlmMetadata: XLMMetadata?
}

extension WalletOptions {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        domains = try values.decodeIfPresent(Domains.self, forKey: .domains)
        xlmMetadata = try values.decodeIfPresent(XLMMetadata.self, forKey: .xlm)
        if let xlmExchangeAddressContainer = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .xlmExchange) {
            xlmExchangeAddresses = try xlmExchangeAddressContainer.decodeIfPresent([String].self, forKey: .exchangeAddresses)
        } else {
            xlmExchangeAddresses = nil
        }
        hotWalletAddresses = try values.decodeIfPresent([String: [String: String]].self, forKey: .hotWalletAddresses)
    }
}
