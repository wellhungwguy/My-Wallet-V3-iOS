// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BitcoinChainKit
import MoneyKit
import PlatformKit

struct BitcoinHistoricalTransaction: Decodable, BitcoinChainHistoricalTransactionResponse {

    static let requiredConfirmations: Int = 3

    // MARK: - Output

    struct Output: Decodable, Equatable {
        let spent: Bool
        let change: Bool
        let amount: CryptoValue
        let address: String

        struct Xpub: Codable, Equatable {
            let value: String

            enum CodingKeys: String, CodingKey {
                case value = "m"
            }
        }

        enum CodingKeys: String, CodingKey {
            case spent
            case xpub
            case amount = "value"
            case address = "addr"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.spent = try values.decode(Bool.self, forKey: .spent)
            let satoshis = try values.decode(Int.self, forKey: .amount)
            self.amount = CryptoValue.create(minor: BigInt(satoshis), currency: .bitcoin)
            self.address = try values.decode(String.self, forKey: .address)
            let xpub = try values.decodeIfPresent(Xpub.self, forKey: .xpub)
            self.change = xpub != nil
        }
    }

    // MARK: - Input

    struct Input: Decodable, Equatable {
        let previousOutput: Output

        enum CodingKeys: String, CodingKey {
            case previousOutput = "prev_out"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.previousOutput = try values.decode(Output.self, forKey: .previousOutput)
        }
    }

    // MARK: - Properties

    /**
     The transaction identifier, used for equality checking and backend calls.

     - Note: For Bitcoin, this is identical to `transactionHash`.
     */
    var identifier: String {
        transactionHash
    }

    let direction: Direction
    let fromAddress: BitcoinAssetAddress
    let toAddress: BitcoinAssetAddress
    let amount: CryptoValue
    let transactionHash: String
    let createdAt: Date
    let fee: CryptoValue?
    let note: String?
    let inputs: [Input]
    let outputs: [Output]
    let blockHeight: Int?
    var confirmations: Int = 0
    var isConfirmed: Bool {
        confirmations >= BitcoinHistoricalTransaction.requiredConfirmations
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "hash"
        case amount = "result"
        case blockHeight = "block_height"
        case time
        case fee
        case inputs
        case outputs = "out"
    }

    // MARK: - Decodable

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let amount = try values.decode(Int64.self, forKey: .amount)
        let originalValue = BigInt(amount)
        var absoluteValue = originalValue
        absoluteValue.sign = .plus
        self.amount = CryptoValue.create(minor: absoluteValue, currency: .bitcoin)
        self.direction = originalValue.sign == .minus ? .credit : .debit
        self.transactionHash = try values.decode(String.self, forKey: .identifier)
        self.blockHeight = try values.decodeIfPresent(Int.self, forKey: .blockHeight)
        self.createdAt = try values.decode(Date.self, forKey: .time)
        self.inputs = try values.decode([Input].self, forKey: .inputs)
        let feeValue = try values.decode(Int.self, forKey: .fee)
        self.fee = CryptoValue.create(minor: BigInt(feeValue), currency: .bitcoin)
        self.outputs = try values.decode([Output].self, forKey: .outputs)

        guard let destinationOutput = outputs.first else {
            throw DecodingError.dataCorruptedError(
                forKey: .outputs,
                in: values,
                debugDescription: "Expected a destination output"
            )
        }

        guard let fromOutput = inputs.first?.previousOutput else {
            throw DecodingError.dataCorruptedError(
                forKey: .outputs,
                in: values,
                debugDescription: "Expected a from output"
            )
        }
        self.toAddress = BitcoinAssetAddress(publicKey: destinationOutput.address)
        self.fromAddress = BitcoinAssetAddress(publicKey: fromOutput.address)

        self.note = nil
    }

    func applying(latestBlockHeight: Int) -> Self {
        var transaction = self

        guard let blockHeight = transaction.blockHeight else {
            transaction.confirmations = 0
            return transaction
        }

        transaction.confirmations = (latestBlockHeight - blockHeight) + 1

        return transaction
    }
}
