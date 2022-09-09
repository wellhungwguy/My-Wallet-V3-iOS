// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift
import RxToolKit
import TestKit
import XCTest

final class ObservableAsPublisherTests: XCTestCase {

    static let timeout: TimeInterval = 1

    var bag: DisposeBag!

    override func setUp() {
        super.setUp()
        bag = DisposeBag()
    }

    func test_int() throws {
        let source = Observable.range(start: 1, count: 100)
        let values = try source.asPublisher()
            .collect()
            .wait(timeout: Self.timeout)
        XCTAssertEqual(values, Array(1...100))
    }

    func test_string() throws {
        let input = "blockchain.com".map(String.init)
        let source = Observable.from(input)
        let values = try source.asPublisher()
            .collect()
            .wait(timeout: Self.timeout)
        XCTAssertEqual(values, input)
    }

    func test_failing() throws {

        enum Test: Error { case error }

        let source = Observable.range(start: 1, count: 100)
        var values: [Int] = []
        XCTAssertThrowsError(
            try source
                .map { i throws -> Int in
                    guard i < 15 else { throw Test.error }
                    return i
                }
                .asPublisher()
                .handleEvents(receiveOutput: { i in
                    values.append(i)
                })
                .collect()
                .wait(timeout: Self.timeout)
        ) { error in
            XCTAssertEqual(values, Array(1..<15))
            XCTAssertTrue(error is Test)
        }
    }

    func test_delayed() throws {

        let expect = expectation(description: "completion")

        let source = Observable
            .from(1...10)
            .delay(.milliseconds(20), scheduler: MainScheduler.instance)
            .do(onCompleted: { expect.fulfill() })

        let values = try source.asPublisher()
            .collect()
            .wait(timeout: Self.timeout)

        wait(for: [expect], timeout: Self.timeout)
        XCTAssertEqual(values, Array(1...10))
    }

    func test_concurrency() throws {

        let routes = Set(
            Either.randomRoutes(
                count: 1000,
                in: Array(0...2),
                and: "abcd".map(String.init),
                bias: 0.1,
                length: 5...7
            )
            .compactMap(\.first)
        )

        let subjects = Dictionary(
            uniqueKeysWithValues: routes.map { route in
                (route, PassthroughSubject<Either<Int, String>, Never>())
            }
        )

        var actual: Set<Either<Int, String>> = []

        for (i, route) in routes.enumerated() {
            let e = expectation(description: "\(i)")
            subjects[route]?
                .asObservable()
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onNext: { event in
                    actual.insert(event)
                    e.fulfill()
                })
                .disposed(by: bag)
        }

        let q = (1...4).map { i in
            DispatchQueue(label: "q[\(i)]", attributes: .concurrent)
        }

        for (i, route) in routes.enumerated() {
            q[i % q.count].asyncAfter(deadline: .now() + .random(in: 0...0.01)) {
                subjects[route]?.send(route)
            }
        }

        waitForExpectations(timeout: Self.timeout)
        XCTAssertEqual(routes, actual)
    }
}
