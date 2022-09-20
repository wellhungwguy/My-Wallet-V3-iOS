// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadKit
import XCTest

class WalletCryptoTests: XCTestCase {

    func test_hash_100_times_should_compute_correct_hash() {
        let hashed = hashNTimes(iterations: 100, value: "setze jutges d'un jutjat mengen fetge d'un penjat")
        XCTAssertEqual(hashed, "bb60847b9b18d2c73dbc6066b036554c430f3bedd64cd84c14b9643bf911a3fe")

        let hashedTwo = hashNTimes(iterations: 2, value: "")
        XCTAssertEqual(hashedTwo, "5df6e0e2761359d30a8275058e299fcc0381534545f55cf43e41983f5d4c9456")
    }

    func test_decrypt_value_using_second_password() throws {
        let encryptedSeedHex = "YSxSY3q6gfjrmVoRg8GbJU9gyqFFQxitGEmxBKbmE40av+Daa/WIBQf2yguYlrEKPd5O2fgrJVmw9Otf2iVH5w=="
        let secPassword = "secret"
        let decryptedSeedHex = try decryptValue(
            using: secPassword,
            sharedKey: "8a260b2b-5257-4357-ac56-7a7efca323ea",
            pbkdf2Iterations: 5000,
            value: encryptedSeedHex
        ).get()

        XCTAssertEqual(decryptedSeedHex, "6a4d9524d413fdf69ca1b5664d1d6db0")
    }

    func test_hash_password_returns_correct_value() {
        let password = "aRandomPassword"
        let expectedHash = "eccba"

        let hashed = hashPassword(password)
        XCTAssertEqual(hashed, expectedHash)
        XCTAssertEqual(hashed.count, 5)
    }
}
