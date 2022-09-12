// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import ToolKit
import WalletPayloadKit

final class RecoveryPhraseStatusProvider: RecoveryPhraseStatusProviding {

    let isRecoveryPhraseVerifiedAtomic: Atomic<Bool> = .init(false)
    let fetchTriggerSubject = PassthroughSubject<Void, Never>()
    let isRecoveryPhraseVerified: AnyPublisher<Bool, Never>

    private let mnemonicVerificationStatusProvider: MnemonicVerificationStatusProvider

    init(
        mnemonicVerificationStatusProvider: @escaping MnemonicVerificationStatusProvider
    ) {
        self.mnemonicVerificationStatusProvider = mnemonicVerificationStatusProvider

        isRecoveryPhraseVerified = fetchTriggerSubject
            .prepend(())
            .flatMap { _ -> AnyPublisher<Bool, Never> in
                mnemonicVerificationStatusProvider()
            }
            .handleEvents(
                receiveOutput: { [isRecoveryPhraseVerifiedAtomic] value in
                    isRecoveryPhraseVerifiedAtomic.mutate { $0 = value }
                }
            )
            .eraseToAnyPublisher()
    }
}
