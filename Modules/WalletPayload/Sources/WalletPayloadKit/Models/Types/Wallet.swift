// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit
import WalletCore

/// The derived Wallet from the response model, `BlockchainWallet`
/// Note: This should be renamed to `Wallet` once we finalise the migration to native code.
public struct NativeWallet: Equatable {
    public let guid: String
    public let sharedKey: String
    public let doubleEncrypted: Bool
    public let doublePasswordHash: String?
    public let metadataHDNode: String?
    public let options: Options
    public let hdWallets: [HDWallet]
    public let addresses: [Address]
    public let txNotes: [String: String]?

    // The following is still present in json but not used on iOS
    public let addressBook: [AddressBookEntry]?

    /// Returns the default HDWallet from the list
    /// - NOTE: We never add multiple HDWallet(s)
    var defaultHDWallet: HDWallet? {
        hdWallets.first
    }

    /// Returns `true` if the mnemonic has been previously marked as verified
    /// otherwise `false
    var isMnemonicVerified: Bool {
        defaultHDWallet?.mnemonicVerified ?? false
    }

    var isHDWallet: Bool {
        !hdWallets.isEmpty
    }

    var spendableActiveAddresses: [String] {
        addresses.lazy
            .filter { !$0.isArchived && !$0.isWatchOnly }
            .map(\.addr)
    }

    public init(
        guid: String,
        sharedKey: String,
        doubleEncrypted: Bool,
        doublePasswordHash: String?,
        metadataHDNode: String?,
        options: Options,
        hdWallets: [HDWallet],
        addresses: [Address],
        txNotes: [String: String]?,
        addressBook: [AddressBookEntry]?
    ) {
        self.guid = guid
        self.sharedKey = sharedKey
        self.doubleEncrypted = doubleEncrypted
        self.doublePasswordHash = doublePasswordHash
        self.metadataHDNode = metadataHDNode
        self.options = options
        self.hdWallets = hdWallets
        self.addresses = addresses
        self.txNotes = txNotes
        self.addressBook = addressBook
    }
}

// MARK: - Wallet Creation

/// Generates a new `Wallet` from the given context
/// - Parameter context: A `WalletCreationContext`
/// - Returns: A `Result<NativeWallet, WalletCreateError>`
func generateWallet(context: WalletCreationContext) -> Result<NativeWallet, WalletCreateError> {
    generateHDWallet(mnemonic: context.mnemonic, accountName: context.accountName, totalAccounts: context.totalAccounts)
        .map { hdWallet in
            NativeWallet(
                guid: context.guid,
                sharedKey: context.sharedKey,
                doubleEncrypted: false,
                doublePasswordHash: nil,
                metadataHDNode: nil,
                options: Options.default,
                hdWallets: [hdWallet],
                addresses: [],
                txNotes: [:],
                addressBook: []
            )
        }
}

/// Retrieves a `WalletCore.HDWallet` from the given mnemonic
/// - Parameter mnemonic: A `String` to be used as the mnemonic phrase
/// - Returns:  A `Result<HDWallet, WalletCreateError>`
func getHDWallet(
    from mnemonic: String
) -> Result<WalletCore.HDWallet, WalletCreateError> {
    guard let wallet = WalletCore.HDWallet(mnemonic: mnemonic, passphrase: "") else {
        return .failure(.mnemonicFailure(.unableToProvide))
    }
    return .success(wallet)
}

/// Retrieves the entropy in hex format from the given mnemonic
/// - Parameter mnemonic: A `String` to be used as the mnemonic phrase
/// - Returns: A `Result<String, WalletCreateError>` that contains either the seed in hexadecimal format or failure
func getSeedHex(
    from mnemonic: String
) -> Result<String, WalletCreateError> {
    getHDWallet(from: mnemonic)
        .map(\.entropy)
        .map(\.toHexString)
}

// MARK: - Wallet Methods

/// Gets a mnemonic phrase from the given wallet
/// - Parameters:
///   - wallet: A `Wallet` value to retrieve the mnemonic from
///   - secondPassword: A optional `String` representing the second password of the wallet
/// - Returns: A `Mnemonic` phrase
func getMnemonic(
    from wallet: NativeWallet,
    secondPassword: String? = nil
) -> Result<String, WalletError> {
    getSeedHex(from: wallet, secondPassword: secondPassword)
        .map(Data.init(hex:))
        .flatMap(getHDWallet(from:))
        .map(\.mnemonic)
}

/// Gets the masterNode (BIP39 seed) from the given wallet
/// This is used to calculate the derivations, xpriv/xpubs etc
///
/// - Parameters:
///   - wallet: A `Wallet` value to retrieve the mnemonic from
///   - secondPassword: A optional `String` representing the second password of the wallet
/// - Returns: A `String` of the seed
func getMasterNode(
    from wallet: NativeWallet,
    secondPassword: String? = nil
) -> Result<String, WalletError> {
    getSeedHex(from: wallet, secondPassword: secondPassword)
        .map(Data.init(hex:))
        .flatMap(getHDWallet(from:))
        .map(\.seed)
        .map(\.toHexString)
}

/// Returns  the seedHex from the given wallet
/// - Parameters:
///   - wallet: A `Wallet` object to retrieve the seedHex
///   - secondPassword: An optional String representing the second password
/// - Returns: `Result<String, WalletError>`
func getSeedHex(
    from wallet: NativeWallet,
    secondPassword: String? = nil
) -> Result<String, WalletError> {
    guard let seedHex = wallet.defaultHDWallet?.seedHex else {
        return .failure(.initialization(.missingSeedHex))
    }
    if wallet.doubleEncrypted {
        guard let secondPassword = secondPassword else {
            return .failure(.initialization(.needsSecondPassword))
        }
        return decryptValue(
            secondPassword: secondPassword,
            wallet: wallet,
            value: seedHex
        )
    }
    return .success(seedHex)
}

// MARK: - Second Password

/// Decrypts a value using a second password
/// - Parameters:
///   - secondPassword: A `String` value representing the user's second password
///   - wallet: A `Wallet` object
///   - value: A `String` encrypted value to be decrypted
/// - Returns: A `Result<String, WalletError>` with a decrypted value or a failure
func decryptValue(
    secondPassword: String,
    wallet: NativeWallet,
    value: String
) -> Result<String, WalletError> {
    validateSecondPassword(
        password: secondPassword,
        wallet: wallet
    ) { wallet in
        decryptValue(
            using: secondPassword,
            sharedKey: wallet.sharedKey,
            pbkdf2Iterations: wallet.options.pbkdf2Iterations,
            value: value
        )
        .mapError(WalletError.map(from:))
    }
}

/// Validates if a second password is correct or fails
/// - Parameters:
///   - password: A `String` value representing the user's second password
///   - wallet: A `Wallet` value
///   - perform: A closure to perform second password decryption
/// - Returns: `Result<Value, WalletError>`
func validateSecondPassword<Value>(
    password: String,
    wallet: NativeWallet,
    perform: (NativeWallet) -> Result<Value, WalletError>
) -> Result<Value, WalletError> {
    guard isValid(secondPassword: password, wallet: wallet) else {
        return .failure(.initialization(.invalidSecondPassword))
    }
    return perform(wallet)
}

/// Validates whether the given second password is valid
/// - Parameters:
///   - secondPassword: A `String` for the second password
///   - wallet: A `Wallet` value
/// - Returns: `true` if the given secondPassword matches the stored one, otherwise `false`
func isValid(secondPassword: String, wallet: NativeWallet) -> Bool {
    guard wallet.doubleEncrypted else {
        return false
    }
    let iterations = wallet.options.pbkdf2Iterations
    let sharedKey = wallet.sharedKey
    let computedHash = hashNTimes(iterations: iterations, value: sharedKey + secondPassword)
    return wallet.doublePasswordHash == computedHash
}

// MARK: Private

/// Gets an HDWallet from the given parameters
/// - Parameters:
///   - entropy: A `Data` value representing the entropy for the `HDWallet`
/// - Returns: A `WalletCore.HDWallet` object
private func getHDWallet(
    from entropy: Data
) -> Result<WalletCore.HDWallet, WalletError> {
    getHDWallet(from: entropy, passphrase: "")
}

/// Gets an HDWallet from the given parameters
/// - Parameters:
///   - entropy: A `Data` value representing the entropy for the `HDWallet`
///   - passphrase: An optional `String` if the HDWallet is encrypted
/// - Returns: A `WalletCore.HDWallet` object
private func getHDWallet(
    from entropy: Data,
    passphrase: String = ""
) -> Result<WalletCore.HDWallet, WalletError> {
    guard let hdWallet = WalletCore.HDWallet(entropy: entropy, passphrase: passphrase) else {
        return .failure(.decryption(.hdWalletCreation))
    }
    return .success(hdWallet)
}
