// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import BitcoinChainKit
import MoneyKit
import PlatformKit
import XCTest

class CoinSelectionTests: XCTestCase {

    private static let feePerByte = BigUInt(55)

    var feePerByte: BigUInt!
    var calculator: TransactionSizeCalculating!
    var subject: CoinSelection!

    override func setUp() {
        super.setUp()
        feePerByte = CoinSelectionTests.feePerByte
        calculator = TransactionSizeCalculator()
        subject = CoinSelection(calculator: calculator)
    }

    override func tearDown() {
        feePerByte = nil
        calculator = nil
        subject = nil
        super.tearDown()
    }

    func test_ascent_draw_selection_with_no_unspent() throws {
        let coins = unspents([])
        let strategy = AscentDrawSortingStrategy()
        let inputs = CoinSelectionInputs(
            target: .init(value: 0, scriptType: .P2PKH),
            feePerByte: feePerByte,
            unspentOutputs: coins,
            sortingStrategy: strategy,
            changeOutputType: .P2PKH
        )
        let result = subject.select(inputs: inputs)
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssertEqual(error as? CoinSelectionError, .noCoinsToSelect)
        }
    }

    func test_ascent_draw_selection_with_no_fee() throws {
        let coins = unspents([1, 2, 3])
        let strategy = AscentDrawSortingStrategy()
        let inputs = CoinSelectionInputs(
            target: .init(value: 0, scriptType: .P2PKH),
            feePerByte: 0,
            unspentOutputs: coins,
            sortingStrategy: strategy,
            changeOutputType: .P2PKH
        )
        let result = subject.select(inputs: inputs)
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssertEqual(error as? CoinSelectionError, .noSelectedCoins)
        }
    }

    func test_ascent_draw_selection_with_fee() throws {
        let inputs = CoinSelectionInputs(
            target: .init(value: 10000, scriptType: .P2PKH),
            feePerByte: feePerByte,
            unspentOutputs: unspents([1, 20000, 300000]),
            sortingStrategy: AscentDrawSortingStrategy(),
            changeOutputType: .P2PKH
        )
        let result = subject.select(inputs: inputs)
        let selected = unspents([20000, 300000])
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: selected,
            absoluteFee: 20570, // (10 + (2 * 148) + (2 * 34)) * 55 = 20570
            amount: 10000,
            change: 289430
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs.spendableOutputs, expectedOutputs.spendableOutputs)
        XCTAssertEqual(outputs.absoluteFee, expectedOutputs.absoluteFee)
        XCTAssertEqual(outputs.amount, expectedOutputs.amount)
        XCTAssertEqual(outputs.change, expectedOutputs.change)
    }

    func test_ascent_draw_selection_with_change_output() throws {
        let inputs = CoinSelectionInputs(
            target: .init(value: 100000, scriptType: .P2PKH),
            feePerByte: feePerByte,
            unspentOutputs: unspents([1, 20000, 0, 0, 300000, 50000, 30000]),
            sortingStrategy: AscentDrawSortingStrategy(),
            changeOutputType: .P2PKH
        )
        let result = subject.select(inputs: inputs)

        let absoluteFee: Int64 = 36850 // (10 + (4 * 148) + (2 * 34)) * 55 = 36850
        let selected = unspents([20000, 30000, 50000, 300000])
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: selected,
            absoluteFee: BigUInt(absoluteFee),
            amount: 100000,
            change: 263150
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs.spendableOutputs, expectedOutputs.spendableOutputs)
        XCTAssertEqual(outputs.absoluteFee, expectedOutputs.absoluteFee)
        XCTAssertEqual(outputs.amount, expectedOutputs.amount)
        XCTAssertEqual(outputs.change, expectedOutputs.change)
    }

    func test_ascent_draw_selection_with_no_change_output() throws {
        let amount: BigUInt = 480000
        let inputs = CoinSelectionInputs(
            target: .init(value: amount, scriptType: .P2PKH),
            feePerByte: feePerByte,
            unspentOutputs: unspents([200000, 300000, 500000]),
            sortingStrategy: AscentDrawSortingStrategy(),
            changeOutputType: .P2PKH
        )
        let result = subject.select(inputs: inputs)
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: unspents([200000, 300000]),
            absoluteFee: (200000 + 300000) - amount,
            amount: amount,
            change: .zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs.spendableOutputs, expectedOutputs.spendableOutputs)
        XCTAssertEqual(outputs.absoluteFee, expectedOutputs.absoluteFee)
        XCTAssertEqual(outputs.amount, expectedOutputs.amount)
        XCTAssertEqual(outputs.change, expectedOutputs.change)
    }

    func test_descent_draw_selection_with_change_output() throws {
        let inputs = CoinSelectionInputs(
            target: .init(value: 100000, scriptType: .P2PKH),
            feePerByte: feePerByte,
            unspentOutputs: unspents([1, 20000, 0, 0, 300000, 50000, 30000]),
            sortingStrategy: DescentDrawSortingStrategy(),
            changeOutputType: .P2PKH
        )
        let result = subject.select(inputs: inputs)

        let absoluteFee: Int64 = 12430 // (10 + (1 * 148) + (2 * 34)) * 55
        let selected = unspents([300000])
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: selected,
            absoluteFee: BigUInt(absoluteFee),
            amount: 100000,
            change: 187570 // 300000 - 100000 - absoluteFee
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs.spendableOutputs, expectedOutputs.spendableOutputs)
        XCTAssertEqual(outputs.absoluteFee, expectedOutputs.absoluteFee)
        XCTAssertEqual(outputs.amount, expectedOutputs.amount)
        XCTAssertEqual(outputs.change, expectedOutputs.change)
    }

    func test_descent_draw_selection_with_no_change_output() throws {
        let amount: BigUInt = 482000
        let inputs = CoinSelectionInputs(
            target: .init(value: amount, scriptType: .P2PKH),
            feePerByte: feePerByte,
            unspentOutputs: unspents([200000, 300000, 500000]),
            sortingStrategy: DescentDrawSortingStrategy(),
            changeOutputType: .P2PKH
        )
        let result = subject.select(inputs: inputs)
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: unspents([500000]),
            absoluteFee: 500000 - amount,
            amount: amount,
            change: .zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs.spendableOutputs, expectedOutputs.spendableOutputs)
        XCTAssertEqual(outputs.absoluteFee, expectedOutputs.absoluteFee)
        XCTAssertEqual(outputs.amount, expectedOutputs.amount)
        XCTAssertEqual(outputs.change, expectedOutputs.change)
    }

    func test_select_all_selection_with_effective_inputs_P2PKH() throws {
        let coins = unspents([1, 20000, 0, 0, 300000])
        let result = subject.select(
            all: coins,
            feePerByte: feePerByte,
            singleOutputType: .P2PKH
        )
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: unspents([20000, 300000]),
            absoluteFee: BigUInt(18700),
            amount: 301300,
            change: .zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }

    func test_select_all_selection_with_effective_inputs_P2WPKH() throws {
        let coins = unspents([1, 20000, 0, 0, 300000])
        let result = subject.select(
            all: coins,
            feePerByte: feePerByte,
            singleOutputType: .P2WPKH
        )
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: unspents([20000, 300000]),
            absoluteFee: BigUInt(18535),
            amount: 301465,
            change: .zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }

    func test_select_all_selection_with_no_inputs() throws {
        let result = subject.select(
            all: [],
            feePerByte: feePerByte,
            singleOutputType: .P2PKH
        )
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: [],
            absoluteFee: .zero,
            amount: .zero,
            change: .zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }

    func test_select_all_selection_with_no_effective_inputs() throws {
        let coins = unspents([1, 10, 100])
        let result = subject.select(
            all: coins,
            feePerByte: feePerByte,
            singleOutputType: .P2PKH
        )
        let expectedOutputs = SpendableUnspentOutputs(
            spendableOutputs: [],
            absoluteFee: .zero,
            amount: .zero,
            change: .zero
        )
        let outputs = try result.get()
        XCTAssertEqual(outputs, expectedOutputs)
    }
}

private func unspents(_ values: [Int]) -> [UnspentOutput] {
    values.compactMap { value in
        let absolute = abs(value)
        let cryptoValue = CryptoValue(amount: BigInt(absolute), currency: .bitcoin)
        return UnspentOutput.createP2PKH(with: cryptoValue)
    }
}
