// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
@testable import MetadataDataKit
@testable import MetadataKit
import XCTest

// swiftlint:disable line_length
final class GenerateNodesTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = nil

        try super.tearDownWithError()
    }

    func testGenerateNodes() throws {

        let environment = TestEnvironment()

        let metadataState = environment.metadataState
        let secondPasswordNode = metadataState.secondPasswordNode

        let successfullyGeneratedExpectation = expectation(
            description: "The root entry was successfully saved"
        )

        let validParametersSavedExpectation = expectation(
            description: "The correct parameters were passed in to the save function"
        )

        let expectedAddress = "12TMDMri1VSjbBw8WJvHmFpvpxzTJe7EhU"

        // swiftlint:disable:next line_length
        let expectedMetadataNodeXPriv = "xprv9uvPCc4bEjZEaAAxnva4d9gnUGPssAVsT8DfnGuLVdtD9TeQfFtfySYD7P1cBAUZSNXnT52zxxmpx4rs2pzCJxu64gpwzUdu33HEzzjbHty"
        let expectedMetadataNode = try PrivateKey
            .bitcoinKeyFromXPriv(
                xpriv: expectedMetadataNodeXPriv
            )
            .get()

        let expected = RemoteMetadataNodes(
            metadataNode: expectedMetadataNode
        )

        let fetch: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            guard let response = MetadataResponse.fetchMagicResponse(for: address) else {
                return .failure(NetworkError.notFoundError)
            }
            return AnyPublisher<MetadataResponse, NetworkError>.just(response)
                .map(MetadataPayload.init(from:))
                .eraseToAnyPublisher()
        }

        let type: EntryType = .root

        let put: PutMetadataEntry = { address, body in
            XCTAssertEqual(address, expectedAddress)

            XCTAssertEqual(body.version, 1)
            XCTAssertEqual(
                body.prevMagicHash,
                "0b08c4e284cef7d60c55abffdade42544db953dbe5fa2890d08e7560b6e8f1b2"
            )
            XCTAssertEqual(body.typeId, Int(type.rawValue))

            return AnyPublisher<MetadataNode, NetworkError>
                .just(secondPasswordNode.metadataNode)
                .flatMap { metadataNode -> AnyPublisher<Void, NetworkError> in
                    decryptMetadata(
                        metadata: metadataNode,
                        payload: body.payload
                    )
                    .publisher
                    .replaceError(with: NetworkError.notFoundError)
                    .mapToVoid()
                }
                .handleEvents(receiveOutput: { _ in
                    validParametersSavedExpectation.fulfill()
                })
                .eraseToAnyPublisher()
        }

        let generateNodes = provideGenerateNodes(
            fetch: fetch,
            put: put
        )

        generateNodes(
            environment.masterKey,
            environment.secondPasswordNode
        )
        .compactMap { $0 }
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Node generation is expecred to succeed: Error: \(error)")
            case .finished:
                break
            }
        }, receiveValue: { metdataState in
            let nodes = metdataState.metadataNodes
            XCTAssertEqual(nodes, expected)
            XCTAssertEqual(nodes.metadataNode.xpriv, expectedMetadataNodeXPriv)
            successfullyGeneratedExpectation.fulfill()
        })
        .store(in: &cancellables)

        wait(
            for: [
                validParametersSavedExpectation,
                successfullyGeneratedExpectation
            ],
            timeout: 10.0
        )
    }
}
