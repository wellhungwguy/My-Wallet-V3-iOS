// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import MetadataKit

extension MetadataState {
    static var mock = MetadataState(
        metadataNodes: metadataNodes,
        secondPasswordNode: secondPasswordNode
    )

    private static var credentials = Credentials(
        guid: "72839398-2680-45ce-9b81-be2ee1f48fba",
        sharedKey: "858dc73f-4877-483a-a10e-54a97e1197ea",
        password: "P5E5LZjwmzsv4rZJhd8mVMdVhYfKUHUn"
    )

    private static var metadataNodeXPriv = "xprv9usvuXHXKk2VR4igogrz9JXxyCEKhauoy4JbHT5TM8HTebb4RUTEtBqwXx1tQApuwYHT1oBM5CLdYTYvqxD8m7P98JC3LcHKRgPMhXpgaHH"

    private static var metadataNodes: RemoteMetadataNodes = {

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

    private static var masterKeyXPrv = "xprv9s21ZrQH143K3rKpAbXs4ymfdYnj3ka7Q5VmWRVr64TCzw8GVs1XH6kJfdDw38f1SkM1Lp4YboZswrFsnrR8xzdN8e3xzbPng65euu7Avcf"
    private static var masterKey: MasterKey = {
        let privateKey = try! PrivateKey
            .bitcoinKeyFromXPriv(
                xpriv: masterKeyXPrv
            )
            .get()
        return MasterKey(privateKey: privateKey)
    }()

    private static var secondPasswordNode: SecondPasswordNode = {
        let node = try! deriveSecondPasswordNode(
            credentials: credentials
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
}
