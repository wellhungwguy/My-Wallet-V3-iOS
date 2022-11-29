import FeatureBackupRecoveryPhraseDomain
import SwiftUI

public struct ViewRecoveryPhraseState: Equatable {
    public var availableWords: [RecoveryPhraseWord] = []
    var recoveryPhraseBackedUp: Bool
    var recoveryPhraseCopied = false
    var blurEnabled: Bool
    var backupLoading: Bool = false
    var exposureEmailSent: Bool = false

    var shouldBlurBackupPhrase: Bool {
        blurEnabled && recoveryPhraseBackedUp
    }

    public init(recoveryPhraseBackedUp: Bool) {
        self.recoveryPhraseBackedUp = recoveryPhraseBackedUp
        self.blurEnabled = recoveryPhraseBackedUp
    }
}
