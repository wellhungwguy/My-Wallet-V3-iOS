// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct WalletResponse: Equatable, Codable {
    let guid: String
    let sharedKey: String
    let doubleEncryption: Bool?
    let doublePasswordHash: String?
    let metadataHDNode: String?
    let options: OptionsResponse
    let addresses: [AddressResponse]
    let hdWallets: [HDWalletResponse]?
    let txNotes: [String: String]?

    // The following is still present in the payload but not used on iOS
    let addressBook: [AddressBookEntryResponse]?

    enum CodingKeys: String, CodingKey {
        case guid
        case sharedKey
        case doubleEncryption = "double_encryption"
        case doublePasswordHash = "dpasswordhash"
        case metadataHDNode
        case options
        case addresses = "keys"
        case hdWallets = "hd_wallets"
        case txNotes = "tx_notes"
        case addressBook = "address_book"
    }
}

extension NativeWallet {
    static func from(blockchainWallet: WalletResponse) -> NativeWallet {
        NativeWallet(
            guid: blockchainWallet.guid,
            sharedKey: blockchainWallet.sharedKey,
            doubleEncrypted: blockchainWallet.doubleEncryption ?? false,
            doublePasswordHash: blockchainWallet.doublePasswordHash,
            metadataHDNode: blockchainWallet.metadataHDNode,
            options: WalletPayloadKit.Options.from(model: blockchainWallet.options),
            hdWallets: blockchainWallet.hdWallets?.map(WalletPayloadKit.HDWallet.from(model:)) ?? [],
            addresses: blockchainWallet.addresses.map(WalletPayloadKit.Address.from(model:)),
            txNotes: blockchainWallet.txNotes,
            addressBook: blockchainWallet.addressBook?.map(WalletPayloadKit.AddressBookEntry.from(model:)) ?? []
        )
    }

    var toWalletResponse: WalletResponse {
        WalletResponse(
            guid: guid,
            sharedKey: sharedKey,
            doubleEncryption: doubleEncrypted,
            doublePasswordHash: doublePasswordHash,
            metadataHDNode: metadataHDNode,
            options: options.toOptionsReponse,
            addresses: addresses.map(\.toAddressResponse),
            hdWallets: hdWallets.map(\.toHDWalletResponse),
            txNotes: txNotes,
            addressBook: addressBook?.map(\.toAddressBookEntryResponse) ?? []
        )
    }
}
