import Blockchain

// earn/eligible

public typealias EarnEligibility = [String: EarnCurrencyEligibility]
public struct EarnCurrencyEligibility: Hashable, Decodable {
    public var eligible: Bool
}

// earn/eligible

public struct EarnUserRates: Hashable, Decodable {

    public struct Rate: Hashable, Decodable {
        public var commission: Double?
        public var rate: Double
    }

    public var rates: [String: Rate]
}

// earn/limits

public typealias EarnLimits = [String: EarnCurrencyLimit]
public struct EarnCurrencyLimit: Hashable, Decodable {
    public var minDepositValue: String
    public var bondingDays: Int?
    public var unbondingDays: Int?
    public var disabledWithdrawals: Bool?
}

// payments/accounts/(staking|savings)

public struct EarnAddress: Hashable, Decodable {
    public let accountRef: String
}

// accounts/(staking|savings)

public typealias EarnAccounts = [String: EarnAccount]
public struct EarnAccount: Hashable, Decodable {
    public var balance: CryptoValue?
    public var pendingDeposit: CryptoValue?
    public var pendingWithdrawal: CryptoValue?
    public var totalRewards: CryptoValue?
    public var pendingRewards: CryptoValue?
    public var bondingDeposits: CryptoValue?
    public var unbondingWithdrawals: CryptoValue?
    public var locked: CryptoValue?
}

extension EarnAccount {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        guard let currency = decoder.codingPath.last.flatMap({ CryptoCurrency(code: $0.stringValue) }) else {
            throw DecodingError.typeMismatch(
                Self.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected to decode a currency container [String: EarnAccount]"
                )
            )
        }
        self.balance = try CryptoValue.create(minor: container.decodeIfPresent(String.self, forKey: "balance").or("0"), currency: currency)
        self.pendingDeposit = try CryptoValue.create(minor: container.decodeIfPresent(String.self, forKey: "pendingDeposit").or("0"), currency: currency)
        self.pendingWithdrawal = try CryptoValue.create(minor: container.decodeIfPresent(String.self, forKey: "pendingWithdrawal").or("0"), currency: currency)
        self.totalRewards = try CryptoValue.create(minor: container.decodeIfPresent(String.self, forKey: "totalRewards").or("0"), currency: currency)
        self.pendingRewards = try CryptoValue.create(minor: container.decodeIfPresent(String.self, forKey: "pendingRewards").or("0"), currency: currency)
        self.bondingDeposits = try CryptoValue.create(minor: container.decodeIfPresent(String.self, forKey: "bondingDeposits").or("0"), currency: currency)
        self.unbondingWithdrawals = try CryptoValue.create(minor: container.decodeIfPresent(String.self, forKey: "unbondingWithdrawals").or("0"), currency: currency)
        self.locked = try CryptoValue.create(minor: container.decodeIfPresent(String.self, forKey: "locked").or("0"), currency: currency)
    }
}

// payments/transactions

public struct EarnActivityList: Hashable, Decodable {
    public let items: [EarnActivity]
}

public struct EarnActivity: Hashable, Decodable {

    public struct State: NewTypeString {
        public var value: String
        public init(_ value: String) { self.value = value }
    }

    public struct ActivityType: NewTypeString {
        public var value: String
        public init(_ value: String) { self.value = value }
    }

    public struct ExtraAttributes: Hashable, Decodable {

        public struct Beneficiary: Hashable, Decodable {
            public let user: String
            public let accountRef: String
        }

        public let address: String?
        public let confirmations: Int?
        public let hash: String?
        public let identifier: String?
        public let transactionHash: String?
        public let transferType: String?
        public let beneficiary: Beneficiary?

        public var isInternalTransfer: Bool {
            guard let type = transferType else { return false }
            return type == "INTERNAL"
        }
    }

    public struct Amount: Hashable, Decodable {
        public let symbol: String
        public let value: String
    }

    public let amount: Amount
    public let amountMinor: String
    public let extraAttributes: ExtraAttributes?
    public let id: String
    public let insertedAt: String
    public let state: State
    public let type: ActivityType

    public var currency: CurrencyType {
        try! CurrencyType(code: amount.symbol)
    }

    public var value: MoneyValue {
        MoneyValue.create(minor: amountMinor, currency: currency) ?? .zero(currency: currency)
    }

    public var date: (insertedAt: Date, ()) {
        (My.iso8601Format.date(from: insertedAt) ?? Date.distantPast, ())
    }

    private static let iso8601Format: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

extension EarnActivity.State {
    public static let failed: Self = "FAILED"
    public static let rejected: Self = "REJECTED"
    public static let processing: Self = "PROCESSING"
    public static let created: Self = "CREATED"
    public static let complete: Self = "COMPLETE"
    public static let pending: Self = "PENDING"
    public static let manualReview: Self = "MANUAL_REVIEW"
    public static let cleared: Self = "CLEARED"
    public static let refunded: Self = "REFUNDED"
    public static let fraudReview: Self = "FRAUD_REVIEW"
    public static let unknown: Self = "UNKNOWN"
}

extension EarnActivity.ActivityType {
    public static let deposit: Self = "DEPOSIT"
    public static let withdraw: Self = "WITHDRAWAL"
    public static let interestEarned: Self = "INTEREST_OUTGOING"
}
