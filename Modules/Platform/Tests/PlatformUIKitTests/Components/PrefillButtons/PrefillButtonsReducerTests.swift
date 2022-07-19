// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformUIKit

import BigInt
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

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.immediate
    }

    func test_stateValues() {
        let state = PrefillButtonsState(
            baseValue: FiatValue(amount: 1000, currency: .USD),
            maxLimit: maxLimit
        )
        XCTAssertEqual(state.baseValue, FiatValue(amount: 1000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[0], FiatValue(amount: 1000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[1], FiatValue(amount: 2000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[2], FiatValue(amount: 4000, currency: .USD))
    }

    func test_stateValues_overMaxLimit() {
        let state = PrefillButtonsState(
            baseValue: FiatValue(amount: 110000, currency: .USD),
            maxLimit: maxLimit
        )
        XCTAssertEqual(state.baseValue, FiatValue(amount: 110000, currency: .USD))
        XCTAssertEqual(state.suggestedValues[0], FiatValue(amount: 110000, currency: .USD))
        XCTAssertEqual(state.suggestedValues.count, 1)
    }

    func test_roundingLastPurchase_after_onAppear() {
        testStore = TestStore(
            initialState: .init(),
            reducer: prefillButtonsReducer,
            environment: PrefillButtonsEnvironment(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                lastPurchasePublisher: .just(lastPurchase),
                maxLimitPublisher: .just(maxLimit),
                onValueSelected: { _ in }
            )
        )
        testStore.send(.onAppear)
        let expected = FiatValue(amount: 1000, currency: .USD)
        testStore.receive(.updateBaseValue(expected)) { state in
            state.baseValue = expected
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
