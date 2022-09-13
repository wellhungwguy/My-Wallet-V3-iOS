// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
@testable import MetadataDataKit
@testable import MetadataKit
import ToolKit
import XCTest

struct TestEnvironment {

    enum Default {

        static let guid = "72839398-2680-45ce-9b81-be2ee1f48fba"
        static let sharedKey = "858dc73f-4877-483a-a10e-54a97e1197ea"
        static let password = "P5E5LZjwmzsv4rZJhd8mVMdVhYfKUHUn"

        static let mnemonicWords = [
            "clump",
            "clump",
            "slim",
            "swap",
            "town",
            "hood",
            "congress",
            "craft",
            "girl",
            "thing",
            "wreck",
            "civil"
        ]

        static let mnemonicString = mnemonicWords.joined(separator: " ")

        // swiftlint:disable:next force_try
        static let mnemonic = try! Mnemonic.from(mnemonicString: mnemonicString).get()

        static let credentials = Credentials(
            guid: guid,
            sharedKey: sharedKey,
            password: password
        )

        static let metadataNodeXPriv = "xprv9usvuXHXKk2VR4igogrz9JXxyCEKhauoy4JbHT5TM8HTebb4RUTEtBqwXx1tQApuwYHT1oBM5CLdYTYvqxD8m7P98JC3LcHKRgPMhXpgaHH"

        static let sharedMetadataNodeXPriv = "xprv9usvuXHbudCrLssoaHAHt2ReANFuQpEaEV6775CkarJtbYZWdQrC3a6Y6Y3L8JyNNdBhVYrR69EDniTFjUyKJdHEpr25eFoUMieKUr87ZgR"

        static let metadataNodes: RemoteMetadataNodes = {

            // swiftlint:disable:next force_try
            let metadataNode = try! MetadataKit.PrivateKey
                .bitcoinKeyFromXPriv(
                    xpriv: metadataNodeXPriv
                )
                .get()
            return RemoteMetadataNodes(
                metadataNode: metadataNode
            )
        }()

        static let metadataState = MetadataState(
            metadataNodes: metadataNodes,
            secondPasswordNode: secondPasswordNode
        )

        static let masterKeyXPrv = "xprv9s21ZrQH143K3rKpAbXs4ymfdYnj3ka7Q5VmWRVr64TCzw8GVs1XH6kJfdDw38f1SkM1Lp4YboZswrFsnrR8xzdN8e3xzbPng65euu7Avcf"

        static let masterKey: MasterKey = {
            let privateKey = try! PrivateKey
                .bitcoinKeyFromXPriv(
                    xpriv: masterKeyXPrv
                )
                .get()
            return MasterKey(privateKey: privateKey)
        }()

        static let secondPasswordNode: SecondPasswordNode = {
            // swiftlint:disable force_try
            let node = try! deriveSecondPasswordNode(
                credentials: Default.credentials
            )
            .get()
            .metadataNode
            .node

            let address = node.address
            let encryptionKey = node.raw
            let type = EntryType.root
            let metadataNode = MetadataNode(
                address: address,
                node: node,
                encryptionKey: encryptionKey,
                type: type
            )
            return SecondPasswordNode(metadataNode: metadataNode)
        }()

        static let putMetadata: PutMetadataEntry = { _, _ -> AnyPublisher<Void, NetworkError> in
            .just(())
        }

        static let fetchMetadata: FetchMetadataEntry = { (_: String)
            -> AnyPublisher<MetadataPayload, NetworkError> in
            .just(MetadataPayload.rootMetadataPayload)
        }
    }

    var metadataNodeXPriv = Default.metadataNodeXPriv

    var sharedMetadataNodeXPriv = Default.sharedMetadataNodeXPriv

    var mnemonic = Default.mnemonic

    var credentials = Default.credentials

    var masterKey = Default.masterKey

    var secondPasswordNode = Default.secondPasswordNode

    var metadataState: MetadataState = Default.metadataState

    var putMetadata: PutMetadataEntry = Default.putMetadata

    var fetchMetadata: FetchMetadataEntry = Default.fetchMetadata

    var masterKeyXPrv: String = Default.masterKeyXPrv
}
