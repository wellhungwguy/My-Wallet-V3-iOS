// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine
import Errors
import WalletCore

protocol BchSigningInputServiceAPI {

    /// Builds a BchSigningInput from a transaction candidate.
    func build(
        candidate: NativeBitcoinTransactionCandidate
    ) -> AnyPublisher<BchSigningInput, NetworkError>
}

final class BchSigningInputService: BchSigningInputServiceAPI {

    private let dustRepository: BchDustRepositoryAPI

    init(dustRepository: BchDustRepositoryAPI) {
        self.dustRepository = dustRepository
    }

    func build(
        candidate: NativeBitcoinTransactionCandidate
    ) -> AnyPublisher<BchSigningInput, NetworkError> {
        dustRepository.dust()
            .map { dust in
                BchSigningInput(
                    spendableOutputs: candidate.utxos,
                    amount: UInt64(candidate.amount.minorAmount),
                    change: UInt64(candidate.change.minorAmount),
                    privateKeys: candidate.keys.map(\.privateKeyData),
                    toAddress: candidate.destinationAddress,
                    changeAddress: candidate.changeAddress,
                    dust: dust
                )
            }
            .eraseToAnyPublisher()
    }
}
