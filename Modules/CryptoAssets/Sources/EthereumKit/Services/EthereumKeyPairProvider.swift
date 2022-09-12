// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

final class EthereumKeyPairProvider {

    var keyPair: AnyPublisher<EthereumKeyPair, Error> {
        mnemonicAccess
            .mnemonic
            .eraseError()
            .flatMap { [deriver] mnenonic in
                deriver
                    .derive(input: EthereumKeyDerivationInput(mnemonic: mnenonic))
                    .publisher
                    .eraseError()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let mnemonicAccess: MnemonicAccessAPI
    private let deriver: EthereumKeyPairDeriver

    // MARK: - Init

    init(
        mnemonicAccess: MnemonicAccessAPI,
        deriver: EthereumKeyPairDeriver
    ) {
        self.mnemonicAccess = mnemonicAccess
        self.deriver = deriver
    }
}
