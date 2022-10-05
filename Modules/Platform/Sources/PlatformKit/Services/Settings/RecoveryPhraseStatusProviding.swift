// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public protocol RecoveryPhraseStatusProviding {
    var isRecoveryPhraseVerifiedAtomic: Atomic<Bool> { get }
    var isRecoveryPhraseVerified: AnyPublisher<Bool, Never> { get }
    var fetchTriggerSubject: PassthroughSubject<Void, Never> { get }
}
