// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct EthereumAddress: Hashable {

    public let publicKey: String
    public let network: EVMNetwork
    public var cryptoCurrency: CryptoCurrency {
        network.nativeAsset
    }

    public init(
        string address: String,
        network: EVMNetwork
    ) throws {
        try EthereumAddressValidator.validate(address: address)
        guard let eip55Address = EthereumAddressValidator.toChecksumAddress(address) else {
            throw AddressValidationError.eip55ChecksumFailed
        }
        self.publicKey = eip55Address
        self.network = network
    }

    public init?(
        address: String,
        network: EVMNetwork
    ) {
        try? self.init(string: address, network: network)
    }
}
