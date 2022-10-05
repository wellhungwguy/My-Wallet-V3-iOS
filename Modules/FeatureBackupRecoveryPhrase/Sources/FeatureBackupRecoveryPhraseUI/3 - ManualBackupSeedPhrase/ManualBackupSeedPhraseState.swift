import FeatureBackupRecoveryPhraseDomain
import SwiftUI

public struct ManualBackupSeedPhraseState: Equatable {
    public var availableWords: [RecoveryPhraseWord] = []
    var recoveryPhraseBackedUp: Bool = false
    var recoveryPhraseCopied: Bool = false

    public init() {}
}
