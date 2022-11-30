// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
@testable import BitcoinChainKitMock
import BlockchainNamespace
import Combine
import TestKit
import ToolKit
import XCTest

class UnspentOutputRepositoryTests: XCTestCase {

    var client: APIClientMock!
    var subject: UnspentOutputRepository!

    override func setUp() {
        super.setUp()
        client = APIClientMock()
        subject = UnspentOutputRepository(client: client, coin: .bitcoin, app: App.test)
    }

    override func tearDown() {
        subject = nil
        client = nil
        super.tearDown()
    }

    func test_fetch_unspent_outputs() {

        let expectedUnspents = UnspentOutputs(outputs: [])

        client.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))

        // Arrange
        let unspentOutputsPublisher = subject
            .unspentOutputs(for: [])

        // Act and Assert
        XCTAssertPublisherValues(unspentOutputsPublisher, expectedUnspents)
    }
}
