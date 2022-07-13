// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import WalletPayloadKit

final class SecuritySectionPresenter: SettingsSectionPresenting {
    let sectionType: SettingsSectionType = .security

    var state: Observable<SettingsSectionLoadingState> {
        nativeWalletFlagEnabled()
            .asObservable()
            .flatMap { [weak self] isEnabled -> Observable<SettingsSectionLoadingState> in
                guard let self = self else {
                    return .empty()
                }
                let showsAddressOption: Bool = !isEnabled
                let top: [SettingsCellViewModel] = [
                    .init(cellType: .switch(.sms2FA, self.smsTwoFactorSwitchCellPresenter)),
                    .init(cellType: .switch(.cloudBackup, self.cloudBackupSwitchCellPresenter)),
                    .init(cellType: .common(.changePassword)),
                    .init(cellType: .badge(.recoveryPhrase, self.recoveryCellPresenter)),
                    .init(cellType: .common(.changePIN)),
                    .init(cellType: .switch(.bioAuthentication, self.bioAuthenticationCellPresenter))
                ]
                let optional: [SettingsCellViewModel] = showsAddressOption
                    ? [.init(cellType: .common(.addresses))]
                    : []
                let afterOptional = [SettingsCellViewModel(cellType: .common(.userDeletion))]

                let items = top + optional + afterOptional
                return .just(
                    .loaded(next:
                        .some(
                            .init(
                                sectionType: self.sectionType,
                                items: items
                            )
                        )
                    )
                )
            }
    }

    private let recoveryCellPresenter: RecoveryStatusCellPresenter
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
        appSettings: BlockchainSettings.App = resolve()
    ) {
        smsTwoFactorSwitchCellPresenter = SMSTwoFactorSwitchCellPresenter(
            service: smsTwoFactorService
        )
        bioAuthenticationCellPresenter = BioAuthenticationSwitchCellPresenter(
            biometryProviding: biometryProvider,
            appSettingsAuthenticating: settingsAuthenticater,
            authenticationCoordinator: authenticationCoordinator
        )
        recoveryCellPresenter = RecoveryStatusCellPresenter(
            recoveryStatusProviding: recoveryPhraseStatusProvider
        )
        cloudBackupSwitchCellPresenter = CloudBackupSwitchCellPresenter(
            appSettings: appSettings,
            credentialsStore: credentialsStore
        )
    }
}
