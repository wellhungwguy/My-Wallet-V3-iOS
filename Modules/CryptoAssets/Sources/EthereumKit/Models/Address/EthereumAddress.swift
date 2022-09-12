// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct EthereumAddress: Hashable {

    public let publicKey: String
    public let network: EVMNetwork
    public var cryptoCurrency: CryptoCurrency {
        network.cryptoCurrency
    }

    public init(
        string address: String,
        network: EVMNetwork = .ethereum
    ) throws {
        try EthereumAddressValidator.validate(address: address)
        guard let eip55Address = EthereumAddressValidator.toChecksumAddress(address) else {
            throw AddressValidationError.eip55ChecksumFailed
        }
        publicKey = eip55Address
        self.network = network
    }

    public init?(
        address: String,
        network: EVMNetwork = .ethereum
    ) {
        try? self.init(string: address)
    }
}
