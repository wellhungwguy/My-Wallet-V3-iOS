// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

import Blockchain
import FeatureOpenBankingData
@testable import FeatureOpenBankingDomain
import FeatureOpenBankingTestFixture
import NetworkKit
import TestKit

// swiftlint:disable line_length

final class OpenBankingTests: XCTestCase {

    var app: AppProtocol!
    var banking: OpenBanking!
    var network: ReplayNetworkCommunicator!
    var scheduler: TestSchedulerOf<DispatchQueue>!
    var actions: [OpenBanking.Action] = []

    // swiftlint:disable:next force_try
    lazy var createAccount = try! network[
        URLRequest(.post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer")
    ]
    .unwrap()
    .decode(to: OpenBanking.BankAccount.self)

    lazy var institution = createAccount.attributes.institutions![1]

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = DispatchQueue.test
        app = App.test
        app.state.set(blockchain.ux.payment.method.open.banking.currency, to: "GBP")
        (banking, network) = OpenBanking.test(app: app, using: scheduler)
        actions = []
    }

    func test_createBankAccount() throws {
        XCTAssertNoThrow(try banking.createBankAccount().wait())
        let request = network.requests[
            .post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer"
        ]
        XCTAssertNotNil(request)
    }

    func start(_ action: OpenBanking.Data.Action) {
        banking.start(
            .init(
                account: createAccount,
                action: action
            )
        )
        .sink { [self] output in
            actions.append(output)
        }
        .teardown(in: self)
    }

    func test_start_link() throws {

        start(.link(institution: institution))

        guard actions.count == 1 else { return XCTFail("Expected 1 action") }
        XCTAssertExtract(/OpenBanking.Action.waitingForConsent, from: actions[0])

        app.state.set(blockchain.ux.payment.method.open.banking.is.authorised, to: true)

        XCTAssertNotNil(
            network.requests[
                .post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/update"
            ]
        )

        XCTAssertNotNil(
            network.requests[
                .get, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c"
            ]
        )
    }

    func test_start_deposit() throws {

        start(.deposit(amountMinor: "1000", product: "SIMPLEBUY"))

        guard actions.count == 1 else { return XCTFail("Expected 1 action, got \(actions.count)") }
        XCTAssertExtract(/OpenBanking.Action.waitingForConsent, from: actions[0])

        app.state.set(blockchain.ux.payment.method.open.banking.is.authorised, to: true)

        XCTAssertNotNil(
            network.requests[
                .post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/payment"
            ]
        )

        XCTAssertNotNil(
            network.requests[
                .get, "https://api.blockchain.info/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a"
            ]
        )
    }
}

extension XCTestCase {

    @discardableResult
    public func XCTAssertExtract<Root, Value>(
        _ expression1: @autoclosure () -> CasePath<Root, Value>,
        from expression2: @autoclosure () -> Root,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Value? {
        let value = expression1().extract(from: expression2())
        XCTAssertNotNil(value, message(), file: file, line: line)
        return value
    }
}
