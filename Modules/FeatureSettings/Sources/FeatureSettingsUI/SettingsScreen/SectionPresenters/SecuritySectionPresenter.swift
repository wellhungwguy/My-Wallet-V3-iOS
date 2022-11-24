// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import WalletPayloadKit

final class SecuritySectionPresenter: SettingsSectionPresenting {
    let sectionType: SettingsSectionType = .security

    var state: Observable<SettingsSectionLoadingState> {
        let items: [SettingsCellViewModel] = [
            .init(cellType: .switch(.sms2FA, smsTwoFactorSwitchCellPresenter)),
            .init(cellType: .switch(.cloudBackup, cloudBackupSwitchCellPresenter)),
            .init(cellType: .common(.changePassword)),
            .init(cellType: .badge(.recoveryPhrase, recoveryCellPresenter)),
            .init(cellType: .common(.changePIN)),
            .init(cellType: .switch(.bioAuthentication, bioAuthenticationCellPresenter)),
            .init(cellType: .common(.userDeletion))
        ]
        let state = SettingsSectionViewModel(sectionType: sectionType, items: items)
        return .just(.loaded(next: .some(state)))
    }

    private let recoveryCellPresenter: BadgeCellPresenting
    private let bioAuthenticationCellPresenter: BioAuthenticationSwitchCellPresenter
    private let smsTwoFactorSwitchCellPresenter: SMSTwoFactorSwitchCellPresenter
    private let cloudBackupSwitchCellPresenter: CloudBackupSwitchCellPresenter

    init(
        smsTwoFactorService: SMSTwoFactorSettingsServiceAPI,
        credentialsStore: CredentialsStoreAPI,
        biometryProvider: BiometryProviding,
        settingsAuthenticater: AppSettingsAuthenticating,
        recoveryPhraseStatusProvider: RecoveryPhraseStatusProviding,
        authenticationCoordinator: AuthenticationCoordinating,
        cloudSettings: CloudBackupConfiguring = resolve()
    ) {
        self.smsTwoFactorSwitchCellPresenter = SMSTwoFactorSwitchCellPresenter(
            service: smsTwoFactorService
        )
        self.bioAuthenticationCellPresenter = BioAuthenticationSwitchCellPresenter(
            biometryProviding: biometryProvider,
            appSettingsAuthenticating: settingsAuthenticater,
            authenticationCoordinator: authenticationCoordinator
        )
        self.recoveryCellPresenter = DefaultBadgeCellPresenter(
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.BackupPhrase.title),
            interactor: RecoveryPhraseBadgeInteractor(provider: recoveryPhraseStatusProvider),
            title: LocalizationConstants.Settings.Badge.recoveryPhrase
        )
        self.cloudBackupSwitchCellPresenter = CloudBackupSwitchCellPresenter(
            cloudSettings: cloudSettings,
            credentialsStore: credentialsStore
        )
    }
}
