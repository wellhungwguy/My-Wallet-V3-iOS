// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import KeychainKit

class KeychainQueryTests: XCTestCase {

    func test_can_build_a_generic_password_query() {
        let genericPasswordQuery = GenericPasswordQuery(
            service: "a-service",
            accessGroup: nil,
            permission: .afterFirstUnlock,
            synchronizable: true
        )

        let query = genericPasswordQuery.commonQuery(key: "a-key", data: nil)

        XCTAssertEqual(
            query[String(kSecClass)] as! String,
            String(kSecClassGenericPassword)
        )

        XCTAssertEqual(
            query[String(kSecAttrService)] as! String,
            "a-service"
        )

        XCTAssertEqual(
            query[String(kSecAttrAccount)] as! String,
            "a-key"
        )

        XCTAssertTrue(
            query[String(kSecAttrSynchronizable)] as! Bool
        )
    }

    func test_can_build_a_write_query() {
        let genericPasswordQuery = GenericPasswordQuery(service: "a-service")
        let data = Data()
        let attributes = genericPasswordQuery.writeQuery(
            key: "a-key",
            data: data
        )

        XCTAssertEqual(
            attributes[String(kSecAttrAccessible)] as! String,
            genericPasswordQuery.permission.queryValue as String
        )
        XCTAssertEqual(
            attributes[String(kSecValueData)] as! Data,
            data
        )
    }

    func test_can_build_a_read_one_query() {
        let genericPasswordQuery = GenericPasswordQuery(service: "a-service")

        let attributes = genericPasswordQuery.readOneQuery(key: "key")

        XCTAssertEqual(
            attributes[String(kSecMatchLimit)] as! String,
            kSecMatchLimitOne as String
        )

        XCTAssertTrue(
            attributes[String(kSecReturnData)] as! Bool
        )
    }
}
