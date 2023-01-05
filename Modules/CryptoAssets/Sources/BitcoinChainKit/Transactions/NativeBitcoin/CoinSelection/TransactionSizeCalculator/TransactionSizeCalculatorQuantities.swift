// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

/// An struct that express the quantity of different types of unspent
/// outputs being used.
struct TransactionSizeCalculatorQuantities {

    static let zero = TransactionSizeCalculatorQuantities(bitcoinScriptTypes: [])

    private let p2pkh: UInt
    private let p2wpkh: UInt
    private let p2sh: UInt
    private let p2wsh: UInt

    var count: UInt {
        p2pkh + p2wpkh + p2sh + p2wsh
    }

    var hasWitness: Bool {
        p2wpkh > 0 || p2wsh > 0
    }

    init(bitcoinScriptTypes: [BitcoinScriptType]) {
        self.p2pkh = UInt(bitcoinScriptTypes.filter { $0 == .P2PKH }.count)
        self.p2wpkh = UInt(bitcoinScriptTypes.filter { $0 == .P2WPKH }.count)
        self.p2sh = UInt(bitcoinScriptTypes.filter { $0 == .P2SH }.count)
        self.p2wsh = UInt(bitcoinScriptTypes.filter { $0 == .P2WSH }.count)
    }

    init(unspentOutputs: [UnspentOutput]) {
        self.init(bitcoinScriptTypes: unspentOutputs.map(\.scriptType))
    }

    var vBytesTotalInput: Decimal {
        var vBytesTotal = Decimal(0)
        vBytesTotal += TransactionCost.PerInput.p2pkh * Decimal(p2pkh)
        vBytesTotal += TransactionCost.PerInput.p2wpkh * Decimal(p2wpkh)
        vBytesTotal += TransactionCost.PerInput.p2sh * Decimal(p2sh)
        vBytesTotal += TransactionCost.PerInput.p2wsh * Decimal(p2wsh)
        return vBytesTotal
    }

    var vBytesTotalOutput: Decimal {
        var vBytesTotal = Decimal(0)
        vBytesTotal += TransactionCost.PerOutput.p2pkh * Decimal(p2pkh)
        vBytesTotal += TransactionCost.PerOutput.p2wpkh * Decimal(p2wpkh)
        vBytesTotal += TransactionCost.PerOutput.p2sh * Decimal(p2sh)
        vBytesTotal += TransactionCost.PerOutput.p2wsh * Decimal(p2wsh)
        return vBytesTotal
    }
}
