// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformUIKit

import BigInt
import BlockchainNamespace
import Combine
import ComposableArchitecture
import MoneyKit
import XCTest

final class PrefillButtonsReducerTests: XCTestCase {

    private var mockMainQueue: ImmediateSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        PrefillButtonsState,
        PrefillButtonsState,
        PrefillButtonsAction,
        PrefillButtonsAction,
        PrefillButtonsEnvironment
    >!
    private let lastPurchase = FiatValue(amount: 900, currency: .USD)
    private let maxLimit = FiatValue(amount: 120000, currency: .USD)

    private let baseValueQuickfillConfigurations: [QuickfillConfiguration] = [
        .init(multiplier: 2.0, rounding: 10),
        .init(multiplier: 2.0, rounding: 50),
        .init(multiplier: 2.0, rounding: 100)
    ].map { .baseValue($0) }

    private let balanceQuickfillConfigurations: [QuickfillConfiguration] = [
        .init(multiplier: 0.25, rounding: [1, 10, 25, 100, 500, 1000]),
        .init(multiplier: 0.5, rounding: [1, 10, 25, 100, 500, 1000]),
        .init(multiplier: 0.75, rounding: [1, 10, 25, 100, 500, 1000])
    ].map { .balance($0) }

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.immediate
    }

    func test_swap_stateValues() {
        let state = PrefillButtonsState(
            previousTxAmount: FiatValue(amount: 6565, currency: .USD),
            action: .swap,
            maxLimit: maxLimit,
            configurations: balanceQuickfillConfigurations
        )
        XCTAssertEqual(state.previousTxAmount, FiatValue(amount: 6565, currency: .USD))
        XCTAssertEqual(state.suggestedValues[0], FiatValue(amount: 30000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[1], FiatValue(amount: 60000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[2], FiatValue(amount: 90000, currency: .USD))
    }

    func test_buy_stateValues() {
        let state = PrefillButtonsState(
            previousTxAmount: FiatValue(amount: 6565, currency: .USD),
            action: .buy,
            maxLimit: maxLimit,
            configurations: baseValueQuickfillConfigurations
        )
        XCTAssertEqual(state.previousTxAmount, FiatValue(amount: 6565, currency: .USD))
        XCTAssertEqual(state.suggestedValues[0], FiatValue(amount: 14000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[1], FiatValue(amount: 30000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[2], FiatValue(amount: 60000, currency: .USD))
    }

    func test_buy_stateValues_overMaxLimit() {
        let state = PrefillButtonsState(
            previousTxAmount: FiatValue(amount: 110000, currency: .USD),
            maxLimit: maxLimit
        )
        XCTAssertEqual(state.previousTxAmount, FiatValue(amount: 110000, currency: .USD))
        XCTAssertTrue(state.suggestedValues.isEmpty)
    }

    func test_roundingLastPurchase_after_onAppear() {
        testStore = TestStore(
            initialState: .init(),
            reducer: prefillButtonsReducer,
            environment: PrefillButtonsEnvironment(
                app: App.test,
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                lastPurchasePublisher: .just(lastPurchase),
                maxLimitPublisher: .just(maxLimit),
                onValueSelected: { _ in }
            )
        )
        testStore.send(.onAppear)
        let expected = FiatValue(amount: 1000, currency: .USD)
        testStore.receive(.updatePreviousTxAmount(expected)) { state in
            state.previousTxAmount = expected
        }
        testStore.receive(.updateMaxLimit(maxLimit)) { [maxLimit] state in
            state.maxLimit = maxLimit
        }
    }

    func test_select_triggersEnvironmentClosure() {
        let e = expectation(description: "Closure should be triggered")
        testStore = TestStore(
            initialState: .init(),
            reducer: prefillButtonsReducer,
            environment: PrefillButtonsEnvironment(
                app: App.test,
                lastPurchasePublisher: .just(lastPurchase),
                maxLimitPublisher: .just(maxLimit),
                onValueSelected: { value in
                    XCTAssertEqual(value.currency, .USD)
                    XCTAssertEqual(value.amount, BigInt(123))
                    e.fulfill()
                }
            )
        )
        testStore.send(.select(.init(amount: 123, currency: .USD)))
        waitForExpectations(timeout: 1)
    }
}
