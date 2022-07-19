// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import NetworkKitMock
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import NetworkKit
import TestKit
import ToolKit
import XCTest

class CreateWalletClientTests: XCTestCase {

    func test_client_can_provide_correct_default_parameters() {

        let mockNetworkAdapter = NetworkAdapterMock()
        let client = CreateWalletClient(
            networkAdapter: mockNetworkAdapter,
            requestBuilder: RequestBuilder(config: Network.Config(scheme: "", host: "")),
            apiCodeProvider: { "some-api-code" }
        )

        let time = Int(Date().timeIntervalSince1970 * 1000.0)
        let defaultParameters = client.provideDefaultParameters(
            with: "tests@test.com",
            time: time
        )
        let expectedDefaultParameters = [
            URLQueryItem(
                name: "method",
                value: "insert"
            ),
            URLQueryItem(
                name: "ct",
                value: String(time)
            ),
            URLQueryItem(
                name: "email",
                value: "tests@test.com"
            ),
            URLQueryItem(
                name: "format",
                value: "plain"
            ),
            URLQueryItem(
                name: "api_code",
                value: "some-api-code"
            )
        ]

        XCTAssertEqual(defaultParameters, expectedDefaultParameters)
    }

    func test_client_can_provide_correct_parameters_from_payload() {

        let mockNetworkAdapter = NetworkAdapterMock()
        let client = CreateWalletClient(
            networkAdapter: mockNetworkAdapter,
            requestBuilder: RequestBuilder(config: Network.Config(scheme: "", host: "")),
            apiCodeProvider: { "some-api-code" }
        )

        let payload = WalletCreationPayload(
            data: Data(),
            wrapper: provideDummyWrapper(),
            applyChecksum: { _ in "" }
        )

        let parameters = client.provideWrapperParameters(from: payload)
        let expectedParameters = [
            URLQueryItem(
                name: "guid",
                value: payload.guid
            ),
            URLQueryItem(
                name: "sharedKey",
                value: payload.sharedKey
            ),
            URLQueryItem(
                name: "checksum",
                value: payload.checksum
            ),
            URLQueryItem(
                name: "language",
                value: payload.language
            ),
            URLQueryItem(
                name: "length",
                value: String(payload.length)
            ),
            URLQueryItem(
                name: "old_checksum",
                value: payload.oldChecksum
            ),
            URLQueryItem(
                name: "payload",
                value: String(decoding: payload.innerPayload, as: UTF8.self)
            )
        ]

        XCTAssertEqual(parameters, expectedParameters)
    }

    private func provideDummyWrapper() -> Wrapper {
        let wallet = NativeWallet(
            guid: "guid",
            sharedKey: "sharedKey",
            doubleEncrypted: false,
            doublePasswordHash: nil,
            metadataHDNode: nil,
            options: .default,
            hdWallets: [],
            addresses: [],
            txNotes: nil,
            addressBook: nil
        )
        return Wrapper(
            pbkdf2Iterations: 1,
            version: 4,
            payloadChecksum: "",
            language: "en",
            syncPubKeys: false,
            wallet: wallet
        )
    }
}
