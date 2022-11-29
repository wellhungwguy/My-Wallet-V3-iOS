// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension KYC.UserTier {
    public struct Limits: Decodable, Equatable {
        public let currency: String
        public let daily: Decimal?
        public let annual: Decimal?

        enum CodingKeys: String, CodingKey {
            case currency
            case daily
            case annual
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.currency = try values.decode(String.self, forKey: .currency)
            let dailyRaw = try values.decodeIfPresent(String.self, forKey: .daily) ?? ""
            self.daily = Decimal(string: dailyRaw)
            let annualRaw = try values.decodeIfPresent(String.self, forKey: .annual) ?? ""
            self.annual = Decimal(string: annualRaw)
        }
    }
}
