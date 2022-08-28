// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore
import XCTest

@testable import BlockchainApp

class JSContextHelpersTests: XCTestCase {

    /// Tests that the function provided in the invokeOnce method is invoked correctly
    func testInvokeOnce() {
        let functionExpectation = expectation(description: "Function is evaluated.")

        let jsContext = JSContext()!
        jsContext.invokeOnce(functionBlock: {
            functionExpectation.fulfill()
        }, forJsFunctionName: "foo" as NSString)

        jsContext.evaluateScriptCheckIsOnMainQueue("foo()")

        waitForExpectations(timeout: 0.1)
    }

    /// Tests that once the function provided in the invokeOnce method is invoked,
    /// that it is subsequently cleaned up and set to `undefined`.
    func testInvokeOnceCleanup() {
        let jsContext = JSContext()!
        jsContext.invokeOnce(functionBlock: {
            // Do nothing
        }, forJsFunctionName: "foo" as NSString)

        var value = jsContext.objectForKeyedSubscript("foo")!

        XCTAssertFalse(value.isUndefined)

        value.call(withArguments: [])

        value = jsContext.objectForKeyedSubscript("foo")!

        XCTAssertTrue(value.isUndefined)
    }
}
