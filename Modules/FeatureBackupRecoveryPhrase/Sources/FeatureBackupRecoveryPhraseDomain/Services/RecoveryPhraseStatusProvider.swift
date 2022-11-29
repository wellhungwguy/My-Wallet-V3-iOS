// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import ToolKit
import WalletPayloadKit

public final class RecoveryPhraseStatusProvider: RecoveryPhraseStatusProviding {

    public let isRecoveryPhraseVerifiedAtomic: Atomic<Bool> = .init(false)
    public let fetchTriggerSubject = PassthroughSubject<Void, Never>()
    public let isRecoveryPhraseVerified: AnyPublisher<Bool, Never>

    private let mnemonicVerificationStatusProvider: MnemonicVerificationStatusProvider

    public init(
        mnemonicVerificationStatusProvider: @escaping MnemonicVerificationStatusProvider
    ) {
        self.mnemonicVerificationStatusProvider = mnemonicVerificationStatusProvider

        self.isRecoveryPhraseVerified = fetchTriggerSubject
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
