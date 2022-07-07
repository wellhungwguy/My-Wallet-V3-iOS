// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import ERC20Kit
import FeatureAppDomain
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import UIKit
import WalletPayloadKit

/// Used for canceling publishers
enum WalletCancelations {
    struct FetchId: Hashable {}
    struct DecryptId: Hashable {}
    struct AuthenticationId: Hashable {}
    struct InitializationId: Hashable {}
    struct UpgradeId: Hashable {}
    struct CreateId: Hashable {}
    struct RestoreId: Hashable {}
    struct RestoreFailedId: Hashable {}
    struct AssetInitializationId: Hashable {}
    struct SecondPasswordId: Hashable {}
    struct ForegroundInitCheckId: Hashable {}
}

public enum WalletAction: Equatable {
    case walletFetched(Result<WalletFetchedContext, WalletError>)
}

// swiftlint:disable closure_body_length
extension Reducer where State == CoreAppState, Action == CoreAppAction, Environment == CoreAppEnvironment {
    /// Returns a combined reducer that handles all the wallet related actions
    func walletReducer() -> Self {
        combined(
            with: Reducer { _, action, environment in
                switch action {
                case .wallet(.walletFetched(.success(let value))):
                    // convert to WalletDecryption model
                    let decryption = WalletDecryption(
                        guid: value.guid,
                        sharedKey: value.sharedKey,
                        passwordPartHash: value.passwordPartHash
                    )
                    // send the legacy actions
                    // this is temporary once we completely move to native wallet login
                    return .merge(
                        Effect(value: .didDecryptWallet(decryption)),
                        Effect(value: .authenticated(.success(true)))
                    )

                case .wallet(.walletFetched(.failure(.initialization(.needsSecondPassword)))):
                    // we don't support double encryoted password wallets
                    environment.loadingViewPresenter.hide()
                    return Effect(
                        value: .onboarding(.informSecondPasswordDetected)
                    )

                case .wallet(.walletFetched(.failure(let error))):
                    // hide loader if any
                    environment.loadingViewPresenter.hide()
                    // show alert
                    let buttons: CoreAlertAction.Buttons = .init(
                        primary: .default(
                            TextState(verbatim: LocalizationConstants.ErrorAlert.button),
                            action: .send(.alert(.dismiss))
                        ),
                        secondary: nil
                    )
                    let alertAction = CoreAlertAction.show(
                        title: LocalizationConstants.Errors.error,
                        message: error.errorDescription ?? LocalizationConstants.Errors.genericError,
                        buttons: buttons
                    )
                    return .merge(
                        Effect(value: .alert(alertAction)),
                        .cancel(id: WalletCancelations.FetchId()),
                        Effect(value: .onboarding(.handleWalletDecryptionError))
                    )

                default:
                    return .none
                }
            }
        )
    }
}
