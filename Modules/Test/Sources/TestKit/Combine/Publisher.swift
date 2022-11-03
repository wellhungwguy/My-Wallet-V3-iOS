// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import XCTest

extension Publisher {

    public func wait(
        for times: Int = 0,
        description: String = #function,
        timeout: TimeInterval = 0.1,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Output {
        let promise = XCTestExpectation(description: description)
        var count = 0
        var output: Output?
        var error: Failure?
        let cancellable = sink { _completion in
            switch _completion {
            case .failure(let e):
                error = e
            case .finished:
                break
            }
        } receiveValue: { _output in
            count += 1
            output = _output
            if times == count {
                promise.fulfill()
            }
        }
        XCTWaiter().wait(for: [promise], timeout: timeout)
        cancellable.cancel()

        if let error { throw error }

        return try XCTUnwrap(output, file: file, line: line)
    }
}

extension Publisher {

    public func complete(
        description: String = #function,
        timeout: TimeInterval = 0.1,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Output {
        let promise = XCTestExpectation(description: description)
        var completion: Subscribers.Completion<Failure>?

        var count = 0
        var output: Output?
        let cancellable = sink { _completion in
            completion = _completion
            promise.fulfill()
        } receiveValue: { _output in
            count += 1
            output = _output
        }
        XCTWaiter().wait(for: [promise], timeout: timeout)
        cancellable.cancel()

        switch try XCTUnwrap(completion, file: file, line: line) {
        case .failure(let error):
            throw error
        case .finished:
            return try XCTUnwrap(output, file: file, line: line)
        }
    }
}

extension AnyCancellable {

    public func teardown(in testCase: XCTestCase) {
        testCase.addTeardownBlock(cancel)
    }
}
