// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
@testable import FeatureOpenBankingData
@testable import FeatureOpenBankingDomain
import FeatureOpenBankingTestFixture
@testable import NetworkKit
import TestKit

final class OpenBankingTests: XCTestCase {

    var app: AppProtocol!
    var banking: OpenBankingClient!
    var network: ReplayNetworkCommunicator!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = App.test
        app.state.set(blockchain.ux.payment.method.open.banking.currency, to: "GBP")
        (banking, network) = OpenBankingClient.test(app: app)
    }

    func test_handle_consent_token_without_callback_path() throws {
        app.state.set(blockchain.ux.payment.method.open.banking.consent.token, to: "token")
        let error: OpenBanking.Error = try app.state.result(for: blockchain.ux.payment.method.open.banking.consent.error).decode().get()
        XCTAssertEqual(error, .namespace(.keyDoesNotExist(blockchain.ux.payment.method.open.banking.callback.path[].reference)))
    }

    func test_handle_consent_token_error() throws {

        network.error(
            URLRequest(.post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/one-time-token")
        )

        app.state.transaction { state in
            state.set(blockchain.ux.payment.method.open.banking.callback.path, to: "/payments/banktransfer/one-time-token")
            state.set(blockchain.ux.payment.method.open.banking.consent.token, to: "token")
        }

        XCTAssertTrue(app.state.contains(blockchain.ux.payment.method.open.banking.consent.error))
        try XCTAssertFalse(XCTUnwrap(app.state.get(blockchain.ux.payment.method.open.banking.is.authorised) as? Bool))
    }

    func test_handle_consent_token() throws {

        app.state.set(blockchain.ux.payment.method.open.banking.callback.path, to: "payments/banktransfer/one-time-token")
        app.state.set(blockchain.ux.payment.method.open.banking.consent.token, to: "token")

        let request = try network.requests[
            .post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/one-time-token"
        ].unwrap()

        try XCTAssertEqual(request.body, ["oneTimeToken": "token"].data())

        try XCTAssertTrue(XCTUnwrap(app.state.get(blockchain.ux.payment.method.open.banking.is.authorised) as? Bool))
        XCTAssertFalse(app.state.contains(blockchain.ux.payment.method.open.banking.consent.error))
    }

    func test_get_all() throws {
        _ = try banking.fetchAllBankAccounts().wait()
        let request = try network.requests[.get, "https://api.blockchain.info/nabu-gateway/payments/banktransfer"].unwrap()
        XCTAssertTrue(request.authenticated)
    }
}

final class OpenBankingBankAccountTests: XCTestCase {

    var app: AppProtocol!
    var banking: OpenBankingClient!
    var network: ReplayNetworkCommunicator!
    var bankAccount: OpenBanking.BankAccount!
    var institution: OpenBanking.Institution!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = App.test
        app.state.set(blockchain.ux.payment.method.open.banking.currency, to: "GBP")
        (banking, network) = OpenBankingClient.test(app: app)
        bankAccount = try banking.createBankAccount().wait()
        institution = bankAccount.attributes.institutions?[1]
    }

    func test_activate_institution() throws {

        let account = try bankAccount.activateBankAccount(with: institution.id, in: banking).wait()

        XCTAssertEqual(account.state, "PENDING")

        let request = try network.requests[
            .post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/update"
        ].unwrap()

        try XCTAssertEqual(
            request.body?.json() as? [String: [String: String]],
            [
                "attributes": [
                    "institutionId": "monzo_ob",
                    "callback": banking.callbackBaseURL.appendingPathComponent("oblinking").absoluteString
                ]
            ]
        )
    }

    func test_get_sets_authorisation_state() throws {

        let account = try bankAccount.get(in: banking).wait()

        XCTAssertEqual(account.id, bankAccount.id)
        try XCTAssertCastEqual(account.attributes.authorisationUrl, app.state.get(blockchain.ux.payment.method.open.banking.authorisation.url))

        XCTAssertEqual(account.attributes.callbackPath, "nabu-gateway/payments/banktransfer/one-time-token")
        try XCTAssertCastEqual(app.state.get(blockchain.ux.payment.method.open.banking.callback.path), "/payments/banktransfer/one-time-token")
    }

    func test_activate_institution_clear_existing_state() throws {

        app.state.set(blockchain.ux.payment.method.open.banking.authorisation.url, to: "url")
        app.state.set(blockchain.ux.payment.method.open.banking.callback.path, to: "path")

        _ = try bankAccount.activateBankAccount(with: institution.id, in: banking).wait()

        XCTAssertThrowsError(try app.state.get(blockchain.ux.payment.method.open.banking.authorisation.url))
        XCTAssertThrowsError(try app.state.get(blockchain.ux.payment.method.open.banking.callback.path))
    }

    func test_delete() throws {

        let promise = expectation(description: "sunk")
        let subscription = bankAccount.delete(in: banking)
            .sink(to: XCTestExpectation.fulfill, on: promise)

        wait(for: [promise], timeout: 1)

        subscription.cancel()

        let request = try network.requests[
            .delete, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c"
        ].unwrap()

        XCTAssertTrue(request.authenticated)
    }

    func test_create_payment() throws {

        let payment = try bankAccount.deposit(
            amountMinor: "1000",
            product: "SIMPLEBUY",
            in: banking
        )
        .wait()

        let request = network.requests[
            .post, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c/payment"
        ]

        try XCTAssertEqual(
            request?.body,
            [
                "currency": "GBP",
                "amountMinor": "1000",
                "product": "SIMPLEBUY",
                "attributes": [
                    "callback": "https://blockchainwallet.page.link/obapproval"
                ]
            ].json(options: .sortedKeys)
        )

        XCTAssertEqual(payment.id, "b039317d-df85-413f-932d-2719346a839a")

        try XCTAssertCastEqual(app.state.get(blockchain.ux.payment.method.open.banking.callback.path), "/payments/banktransfer/one-time-token")
        XCTAssertEqual(payment.attributes.callbackPath, "nabu-gateway/payments/banktransfer/one-time-token")
    }
}

final class OpenBankingBankAccountPollTests: XCTestCase {

    var app: AppProtocol!
    var banking: OpenBankingClient!
    var network: ReplayNetworkCommunicator!
    var bankAccount: OpenBanking.BankAccount!
    var institution: OpenBanking.Institution!
    var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = DispatchQueue.test
        app = App.test
        app.state.set(blockchain.ux.payment.method.open.banking.currency, to: "GBP")
        (banking, network) = OpenBankingClient.test(app: app, using: scheduler)
        bankAccount = try banking.createBankAccount().wait()
        institution = bankAccount.attributes.institutions?[1]
    }

    func get() -> URLRequest {
        URLRequest(.get, "https://api.blockchain.info/nabu-gateway/payments/banktransfer/a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c")
    }

    func test_poll_with_error() throws {

        network[get()] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            error: .bankTransferAccountAlreadyLinked,
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        let account = try bankAccount.poll(in: banking).wait()

        XCTAssertEqual(account.error, .bankTransferAccountAlreadyLinked)
    }

    func test_poll_when_pending() throws {

        let request = get()

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: .pending,
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        var result: Result<OpenBanking.BankAccount, OpenBanking.Error>?
        let subscription = bankAccount.poll(in: banking)
            .result()
            .sink { result = $0 }

        XCTAssertNil(result)

        for _ in 0..<200 {
            scheduler.advance(by: .seconds(2))
        }

        let account = try XCTUnwrap(result)
        XCTAssertThrowsError(try account.get())

        subscription.cancel()
    }

    func test_poll_when_pending_then_eventually_succeed() throws {

        let request = get()

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: .pending,
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        var result: Result<OpenBanking.BankAccount, OpenBanking.Error>?
        let subscription = bankAccount.poll(in: banking)
            .result()
            .sink { result = $0 }

        for _ in 0..<10 {
            scheduler.advance(by: .seconds(2))
        }

        XCTAssertNil(result)

        for _ in 0..<10 {
            scheduler.advance(by: .seconds(2))
        }

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: .active,
            attributes: .init(entity: "SafeConnect(UK)", authorisationUrl: "http://blockchain.com")
        )
        .data()

        scheduler.advance(by: .seconds(2))

        let account = try XCTUnwrap(result).get()

        XCTAssertEqual(account.state, .active)

        subscription.cancel()
    }

    func x_test_poll_realtime() throws {

        (banking, network) = OpenBankingClient.test(app: app, using: DispatchQueue.main)

        let request = get()

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: "PENDING",
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        let promise = expectation(description: "")
        let __ = expectation(description: ""); __.isInverted = true

        var result: Result<OpenBanking.BankAccount, OpenBanking.Error>?

        let subscription = bankAccount.poll(in: banking)
            .result()
            .sink {
                result = $0; promise.fulfill()
            }

        wait(for: [__], timeout: 5)

        network[request] = try OpenBanking.BankAccount(
            id: "a44d7d14-15f0-4ceb-bf32-bdcb6c6b393c",
            partner: "YAPILY",
            state: .active,
            attributes: .init(entity: "SafeConnect(UK)")
        )
        .data()

        wait(for: [promise], timeout: 2)

        subscription.cancel()

        let account = try XCTUnwrap(result).get()

        XCTAssertEqual(account.state, .active)
    }
}

final class OpenBankingPaymentTests: XCTestCase {

    var app: AppProtocol!
    var banking: OpenBankingClient!
    var network: ReplayNetworkCommunicator!
    var bankAccount: OpenBanking.BankAccount!
    var payment: OpenBanking.Payment!
    var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = DispatchQueue.test
        app = App.test
        app.state.set(blockchain.ux.payment.method.open.banking.currency, to: "GBP")
        (banking, network) = OpenBankingClient.test(app: app, using: scheduler)
        bankAccount = try banking.fetchAllBankAccounts().wait().first.unwrap()
        payment = try bankAccount.deposit(amountMinor: "1000", product: "SIMPLEBUY", in: banking).wait()
    }

    func test_get() throws {
        _ = try payment.get(in: banking).wait()
        XCTAssertNoThrow(try app.state.get(blockchain.ux.payment.method.open.banking.authorisation.url))
    }

    func get() -> URLRequest {
        URLRequest(.get, "https://api.blockchain.info/nabu-gateway/payments/payment/b039317d-df85-413f-932d-2719346a839a")
    }

    func test_poll_error() throws {

        network[get()] = try OpenBanking.Payment.Details(
            id: "b039317d-df85-413f-932d-2719346a839a",
            amount: .init(symbol: "GBP", value: "10.00"),
            amountMinor: "1000",
            insertedAt: "DATE",
            state: .failed,
            type: "CHARGE",
            beneficiaryId: "...",
            error: .code("ERROR_CODE")
        )
        .data()

        let details = try payment.poll(in: banking).wait()
        XCTAssertEqual(details.error, .code("ERROR_CODE"))
    }

    func test_poll_pending_timeout() throws {

        network[get()] = try OpenBanking.Payment.Details(
            id: "b039317d-df85-413f-932d-2719346a839a",
            amount: .init(symbol: "GBP", value: "10.00"),
            amountMinor: "1000",
            insertedAt: "DATE",
            state: .pending,
            type: "CHARGE",
            beneficiaryId: "..."
        )
        .data()

        var result: Result<OpenBanking.Payment.Details, OpenBanking.Error>!
        let subscription = payment.poll(in: banking)
            .result()
            .sink { result = $0 }

        scheduler.advance(by: .seconds(2))

        XCTAssertNil(result)

        for _ in 0..<200 {
            scheduler.advance(by: .seconds(2))
        }

        switch try result.unwrap() {
        case .failure(OpenBanking.Error.timeout):
            break
        case let value:
            XCTFail("\(value)")
        }

        subscription.cancel()
    }

    func test_poll_when_pending_then_eventually_succeed() throws {

        network[get()] = try OpenBanking.Payment.Details(
            id: "b039317d-df85-413f-932d-2719346a839a",
            amount: .init(symbol: "GBP", value: "10.00"),
            amountMinor: "1000",
            insertedAt: "DATE",
            state: .pending,
            type: "CHARGE",
            beneficiaryId: "..."
        )
        .data()

        var result: Result<OpenBanking.Payment.Details, OpenBanking.Error>?
        let subscription = payment.poll(in: banking)
            .result()
            .sink { result = $0 }

        for _ in 0..<10 {
            scheduler.advance(by: .seconds(2))
        }

        network[get()] = try OpenBanking.Payment.Details(
            id: "b039317d-df85-413f-932d-2719346a839a",
            amount: .init(symbol: "GBP", value: "10.00"),
            amountMinor: "1000",
            extraAttributes: .init(authorisationUrl: "https://monzo.com"),
            insertedAt: "DATE",
            state: .complete,
            type: "CHARGE",
            beneficiaryId: "..."
        )
        .data()

        scheduler.advance(by: .seconds(2))

        let account = try XCTUnwrap(result).get()

        XCTAssertEqual(account.state, .complete)

        subscription.cancel()
    }
}

public func XCTAssertCastEqual<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: Any,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws where T: Equatable {
    try XCTAssertEqual(expression1(), XCTUnwrap(expression2 as? T), message(), file: file, line: line)
}

public func XCTAssertCastEqual<T>(
    _ expression1: Any,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws where T: Equatable {
    try XCTAssertEqual(expression2(), XCTUnwrap(expression1 as? T), message(), file: file, line: line)
}
