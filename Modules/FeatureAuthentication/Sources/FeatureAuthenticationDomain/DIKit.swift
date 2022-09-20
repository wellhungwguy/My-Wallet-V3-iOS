// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import DIKit
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - FeatureAuthenticationDomain Module

    public static var featureAuthenticationDomain = module {

        // MARK: - Services

        factory { JWTService() as JWTServiceAPI }

        factory { AccountRecoveryService() as AccountRecoveryServiceAPI }

        factory { MobileAuthSyncService() as MobileAuthSyncServiceAPI }

        factory { ResetPasswordService() as ResetPasswordServiceAPI }

        single { PasswordValidator() as PasswordValidatorAPI }

        single { SeedPhraseValidator(words: Set(WalletPayloadKit.WordList.defaultWords)) as SeedPhraseValidatorAPI }

        single { SharedKeyParsingService() }

        // MARK: - NabuAuthentication

        single { NabuAuthenticationExecutor() as NabuAuthenticationExecutorAPI }

        single { NabuAuthenticationErrorBroadcaster() }

        factory { () -> WalletRecoveryService in
            WalletRecoveryService.live(
                walletRecovery: DIKit.resolve()
            )
        }

        factory { () -> WalletCreationService in
            let app: AppProtocol = DIKit.resolve()
            let settingsClient: UpdateSettingsClientAPI = DIKit.resolve()
            return WalletCreationService.live(
                walletCreator: DIKit.resolve(),
                nabuRepository: DIKit.resolve(),
                updateCurrencyService: provideUpdateCurrencyForWallets(app: app, client: settingsClient)
            )
        }

        factory { () -> WalletFetcherService in
            WalletFetcherService.live(
                accountRecoveryService: DIKit.resolve(),
                walletFetcher: DIKit.resolve()
            )
        }

        factory { () -> NabuAuthenticationErrorReceiverAPI in
            let broadcaster: NabuAuthenticationErrorBroadcaster = DIKit.resolve()
            return broadcaster as NabuAuthenticationErrorReceiverAPI
        }

        factory { () -> UserAlreadyRestoredHandlerAPI in
            let broadcaster: NabuAuthenticationErrorBroadcaster = DIKit.resolve()
            return broadcaster as UserAlreadyRestoredHandlerAPI
        }

        factory { () -> NabuAuthenticationExecutorProvider in
            { () -> NabuAuthenticationExecutorAPI in
                DIKit.resolve()
            }
        }

        factory { () -> TwoFAWalletServiceAPI in
            TwoFAWalletService(
                repository: DIKit.resolve(),
                walletRepo: DIKit.resolve()
            )
        }

        factory { () -> WalletPayloadServiceAPI in
            WalletPayloadService(
                repository: DIKit.resolve(),
                walletRepo: DIKit.resolve(),
                credentialsRepository: DIKit.resolve()
            )
        }

        factory { () -> LoginServiceAPI in
            LoginService(
                payloadService: DIKit.resolve(),
                twoFAPayloadService: DIKit.resolve(),
                repository: DIKit.resolve()
            )
        }

        factory { () -> AutoWalletPairingServiceAPI in
            AutoWalletPairingService(
                walletPayloadService: DIKit.resolve(),
                walletPairingRepository: DIKit.resolve(),
                walletCryptoService: DIKit.resolve(),
                parsingService: DIKit.resolve()
            )
        }

        factory { () -> GuidServiceAPI in
            GuidService(
                sessionTokenRepository: DIKit.resolve(),
                guidRepository: DIKit.resolve()
            )
        }

        factory { () -> SessionTokenServiceAPI in
            SessionTokenService(
                sessionRepository: DIKit.resolve()
            )
        }

        factory { () -> SMSServiceAPI in
            SMSService(
                smsRepository: DIKit.resolve(),
                credentialsRepository: DIKit.resolve(),
                sessionTokenRepository: DIKit.resolve()
            )
        }

        factory { () -> EmailAuthorizationServiceAPI in
            EmailAuthorizationService(
                guidService: DIKit.resolve()
            )
        }

        factory { () -> DeviceVerificationServiceAPI in
            DeviceVerificationService(
                deviceVerificationRepository: DIKit.resolve(),
                sessionTokenRepository: DIKit.resolve(),
                recaptchaService: DIKit.resolve()
            )
        }
    }
}
