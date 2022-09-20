// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

class PaymentAccountPatcherTests: XCTestCase {
    var sut: PaymentAccountPatcher!

    override func setUp() {
        super.setUp()
        sut = PaymentAccountPatcher()
    }

    func testIdealEURAccountIsNotPatched() {
        let eurAccount = PaymentAccountEUR(
            identifier: "identifier",
            state: .active,
            bankName: "bankName",
            bankCountry: "bankCountry",
            iban: "iban",
            bankCode: PaymentAccountPatcher.targetBankCode,
            recipientName: "recipientName"
        )

        let result = sut.patch(eurAccount, recipientName: "patched") as! PaymentAccountEUR

        XCTAssertEqual(result, eurAccount, "Complete EUR Account should not be patched")
    }

    func testMinimumEURAccountIsNotPatched() {
        let eurAccount = PaymentAccountEUR(
            identifier: "identifier",
            state: .active,
            bankName: "bankName",
            bankCountry: "",
            iban: "iban",
            bankCode: PaymentAccountPatcher.targetBankCode,
            recipientName: ""
        )

        let result = sut.patch(eurAccount, recipientName: "patched") as! PaymentAccountEUR

        XCTAssertNotEqual(result, eurAccount, "EUR Account should be patched")
        XCTAssertEqual(result.recipientName, "patched", "recipientName should be the given one")
        XCTAssertEqual(result.bankCountry, PaymentAccountPatcher.targetBankCountry, "bankCountry should be the targetBankCountry")
    }
}
