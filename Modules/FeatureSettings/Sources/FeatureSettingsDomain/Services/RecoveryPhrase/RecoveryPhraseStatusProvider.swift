// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import WalletPayloadKit

public final class RecoveryPhraseStatusProvider: RecoveryPhraseStatusProviding {
    public let fetchTriggerSubject = PassthroughSubject<Void, Never>()

    public let isRecoveryPhraseVerifiedPublisher: AnyPublisher<Bool, Never>

    public var isRecoveryPhraseVerified: Bool {
        walletRecoveryVerifier.isRecoveryPhraseVerified()
    }

    private let walletRecoveryVerifier: WalletRecoveryVerifing
    private let mnemonicVerificationStatusProvider: MnemonicVerificationStatusProvider

    public init(
        walletRecoveryVerifier: WalletRecoveryVerifing = resolve(),
        mnemonicVerificationStatusProvider: @escaping MnemonicVerificationStatusProvider = resolve()
    ) {
        self.walletRecoveryVerifier = walletRecoveryVerifier
        self.mnemonicVerificationStatusProvider = mnemonicVerificationStatusProvider

        isRecoveryPhraseVerifiedPublisher = fetchTriggerSubject
            .prepend(())
            .zip(nativeWalletFlagEnabled())
            .flatMap { _, isEnabled -> AnyPublisher<Bool, Never> in
                guard isEnabled else {
                    return .just(walletRecoveryVerifier.isRecoveryPhraseVerified())
                }
                return mnemonicVerificationStatusProvider()
            }
            .eraseToAnyPublisher()
    }
}
