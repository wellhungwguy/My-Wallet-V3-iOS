// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct SwapKind: Decodable, Equatable {

    public let direction: OrderDirection
    public let depositAddress: String?
    public let depositTxHash: String?
    public let withdrawalAddress: String?
    public let withdrawalTxHash: String?

    enum CodingKeys: String, CodingKey {
        case direction
        case depositAddress
        case depositTxHash
        case withdrawalAddress
        case withdrawalTxHash
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.direction = try values.decode(OrderDirection.self, forKey: .direction)
        self.depositAddress = try values.decodeIfPresent(String.self, forKey: .depositAddress)
        self.depositTxHash = try values.decodeIfPresent(String.self, forKey: .depositTxHash)
        self.withdrawalAddress = try values.decodeIfPresent(String.self, forKey: .withdrawalAddress)
        self.withdrawalTxHash = try values.decodeIfPresent(String.self, forKey: .withdrawalTxHash)
    }
}
