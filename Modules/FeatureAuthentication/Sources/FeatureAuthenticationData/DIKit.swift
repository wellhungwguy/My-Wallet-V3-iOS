// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import NetworkKit
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - FeatureAuthenticationData Module

    public static var featureAuthenticationData = module {

        // MARK: - WalletNetworkClients

        factory { AutoWalletPairingClient() as AutoWalletPairingClientAPI }

        factory { GuidClient() as GuidClientAPI }

        factory { SMSClient() as SMSClientAPI }

        factory { SessionTokenClient() as SessionTokenClientAPI }

        factory { TwoFAWalletClient() as TwoFAWalletClientAPI }

        factory { DeviceVerificationClient() as DeviceVerificationClientAPI }

        factory { PushNotificationsClient() as PushNotificationsClientAPI }

        factory { MobileAuthSyncClient() as MobileAuthSyncClientAPI }

        // MARK: - NabuNetworkClients

        factory { JWTClient() as JWTClientAPI }

        factory { NabuUserCreationClient() as NabuUserCreationClientAPI }

        factory { NabuSessionTokenClient() as NabuSessionTokenClientAPI }

        factory { NabuUserRecoveryClient() as NabuUserRecoveryClientAPI }

        factory { NabuResetUserClient() as NabuResetUserClientAPI }

        factory { NabuUserResidentialInfoClient() as NabuUserResidentialInfoClientAPI }

        // MARK: - AppStore

        factory { AppStoreInformationClient() as AppStoreInformationClientAPI }

        // MARK: - Repositories

        factory { JWTRepository() as JWTRepositoryAPI }

        factory { AccountRecoveryRepository() as AccountRecoveryRepositoryAPI }

        factory { DeviceVerificationRepository() as DeviceVerificationRepositoryAPI }

        factory { RemoteSessionTokenRepository() as RemoteSessionTokenRepositoryAPI }

        factory { RemoteGuidRepository() as RemoteGuidRepositoryAPI }

        factory { AutoWalletPairingRepository() as AutoWalletPairingRepositoryAPI }

        factory { TwoFAWalletRepository() as TwoFAWalletRepositoryAPI }

        factory { SMSRepository() as SMSRepositoryAPI }

        factory { MobileAuthSyncRepository() as MobileAuthSyncRepositoryAPI }

        factory { PushNotificationsRepository() as PushNotificationsRepositoryAPI }

        factory { AppStoreInformationRepository() as AppStoreInformationRepositoryAPI }

        // MARK: - Wallet Repositories

        factory { () -> AuthenticatorRepositoryAPI in
            let walletRepository: WalletRepositoryProvider = DIKit.resolve()
            return AuthenticatorRepository(
                walletRepository: walletRepository.repository,
                walletRepo: DIKit.resolve(),
                nativeWalletEnabled: { nativeWalletFlagEnabled() }
            )
        }

        factory { () -> SharedKeyRepositoryAPI in
            let walletRepository: WalletRepositoryProvider = DIKit.resolve()
            return SharedKeyRepository(
                walletRepository: walletRepository.repository,
                walletRepo: DIKit.resolve(),
                nativeWalletEnabled: { nativeWalletFlagEnabled() }
            )
        }

        factory { () -> SessionTokenRepositoryAPI in
            let walletRepository: WalletRepositoryProvider = DIKit.resolve()
            return SessionTokenRepository(
                walletRepository: walletRepository.repository,
                walletRepo: DIKit.resolve(),
                nativeWalletEnabled: { nativeWalletFlagEnabled() }
            )
        }

        factory { () -> GuidRepositoryAPI in
            let walletRepository: WalletRepositoryProvider = DIKit.resolve()
            return GuidRepository(
                walletRepository: walletRepository.repository,
                walletRepo: DIKit.resolve(),
                nativeWalletEnabled: { nativeWalletFlagEnabled() }
            )
        }

        factory { () -> PasswordRepositoryAPI in
            let walletRepository: WalletRepositoryProvider = DIKit.resolve()
            return PasswordRepository(
                walletRepository: walletRepository.repository,
                walletRepo: DIKit.resolve(),
                changePasswordService: DIKit.resolve(),
                nativeWalletEnabled: { nativeWalletFlagEnabled() }
            )
        }

        factory { () -> CredentialsRepositoryAPI in
            let guidRepo: GuidRepositoryAPI = DIKit.resolve()
            let sharedKeyRepo: SharedKeyRepositoryAPI = DIKit.resolve()
            return CredentialsRepository(
                guidRepository: guidRepo,
                sharedKeyRepository: sharedKeyRepo
            )
        }

        single { () -> NabuOfflineTokenRepositoryAPI in
            let repository: WalletRepositoryAPI = DIKit.resolve()
            return NabuOfflineTokenRepository(
                walletRepository: repository,
                credentialsFetcher: DIKit.resolve(),
                reactiveWallet: DIKit.resolve(),
                nativeWalletEnabled: { nativeWalletFlagEnabled() }
            )
        }

        // MARK: - Nabu Authentication

        single { NabuTokenRepository() as NabuTokenRepositoryAPI }

        factory { NabuAuthenticator() as AuthenticatorAPI }

        factory { NabuRepository() as NabuRepositoryAPI }

        factory { () -> CheckAuthenticated in
            unauthenticated as CheckAuthenticated
        }
    }
}

private func unauthenticated(
    communicatorError: NetworkError
) -> AnyPublisher<Bool, Never> {
    guard let authenticationError = NabuAuthenticationError(error: communicatorError),
          case .tokenExpired = authenticationError
    else {
        return .just(false)
    }
    return .just(true)
}
