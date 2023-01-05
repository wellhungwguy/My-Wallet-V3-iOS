// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct SavingsAccountBalanceDetails: Decodable {

    public let balance: String?
    public let pendingInterest: String?
    public let totalInterest: String?
    public let pendingWithdrawal: String?
    public let pendingDeposit: String?

    private enum CodingKeys: String, CodingKey {
        case balance
        case pendingInterest
        case totalInterest
        case pendingWithdrawal
        case pendingDeposit
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.balance = try values.decodeIfPresent(String.self, forKey: .balance)
        self.pendingDeposit = try values.decodeIfPresent(String.self, forKey: .pendingDeposit)
        self.pendingInterest = try values.decodeIfPresent(String.self, forKey: .pendingInterest)
        self.pendingWithdrawal = try values.decodeIfPresent(String.self, forKey: .pendingWithdrawal)
        self.totalInterest = try values.decodeIfPresent(String.self, forKey: .totalInterest)
    }
}
