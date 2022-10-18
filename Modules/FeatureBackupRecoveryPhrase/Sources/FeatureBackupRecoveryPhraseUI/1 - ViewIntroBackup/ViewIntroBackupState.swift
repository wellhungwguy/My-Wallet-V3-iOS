import ComposableArchitecture
import SwiftUI

public struct ViewIntroBackupState: Equatable {
    var backupButtonEnabled: Bool { checkBox1IsOn && checkBox2IsOn && checkBox3IsOn }
    @BindableState var checkBox1IsOn: Bool = false
    @BindableState var checkBox2IsOn: Bool = false
    @BindableState var checkBox3IsOn: Bool = false
    @BindableState var skipConfirmShown: Bool = false
    var recoveryPhraseBackedUp: Bool

    public init(recoveryPhraseBackedUp: Bool) {
        self.recoveryPhraseBackedUp = recoveryPhraseBackedUp
    }
}
