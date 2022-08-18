import Combine
import CombineSchedulers
import Foundation
import TestKit
import ToolKit
import XCTest

final class AsyncSequencePublisherTests: XCTestCase {

    let limit = 10000

    func test_async_sequence_publisher() throws {
        let publisher = Counter(howHigh: limit).publisher().collect()
        let value = try publisher.wait()
        XCTAssertEqual(value, Array(1...limit))
    }

    func test_async_sequence_throwing_publisher() throws {
        let publisher = ThrowingCounter(howHigh: limit).publisher()
        var values: [Int] = []
        let promise = expectation(description: #function)
        publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Expected failure, got success")
                case .failure(ThrowingCounter.Error.limit):
                    break
                case .failure(let error):
                    XCTFail("Expected \(ThrowingCounter.Error.limit) but got \(error)")
                }
                promise.fulfill()
            },
            receiveValue: { value in
                values.append(value)
            }
        )
        .store(withLifetimeOf: self)
        wait(for: [promise], timeout: 0.1)
        XCTAssertEqual(values, Array(1...limit))
    }
}

struct Counter: AsyncSequence {

    typealias Element = Int

    let howHigh: Int

    struct AsyncIterator: AsyncIteratorProtocol {

        let howHigh: Int
        var current = 1

        mutating func next() async -> Int? {
            guard current <= howHigh else { return nil }
            let result = current
            current += 1
            return result
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(howHigh: howHigh)
    }
}

struct ThrowingCounter: AsyncSequence {

    enum Error: Swift.Error {
        case limit
    }

    typealias Element = Int

    let howHigh: Int

    struct AsyncIterator: AsyncIteratorProtocol {

        let howHigh: Int
        var current = 1

        mutating func next() async throws -> Int? {
            guard current <= howHigh else { throw Error.limit }
            let result = current
            current += 1
            return result
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(howHigh: howHigh)
    }
}
