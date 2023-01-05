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
            AuthenticatorRepository(
                walletRepo: DIKit.resolve()
            )
        }

        factory { () -> SharedKeyRepositoryAPI in
            SharedKeyRepository(
                legacySharedKeyRepository: DIKit.resolve(),
                walletRepo: DIKit.resolve()
            )
        }

        factory { () -> SessionTokenRepositoryAPI in
            SessionTokenRepository(
                walletRepo: DIKit.resolve()
            )
        }

        factory { () -> GuidRepositoryAPI in
            GuidRepository(
                legacyGuidRepository: DIKit.resolve(),
                walletRepo: DIKit.resolve()
            )
        }

        factory { () -> PasswordRepositoryAPI in
            PasswordRepository(
                walletRepo: DIKit.resolve(),
                changePasswordService: DIKit.resolve()
            )
        }

        factory { () -> CredentialsRepositoryAPI in
            CredentialsRepository(
                guidRepository: DIKit.resolve(),
                sharedKeyRepository: DIKit.resolve()
            )
        }

        single { () -> NabuOfflineTokenRepositoryAPI in
            NabuOfflineTokenRepository(
                credentialsFetcher: DIKit.resolve(),
                reactiveWallet: DIKit.resolve()
            )
        }

        factory { () -> CheckReferralClientAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            return CheckReferralClient(networkAdapter: adapter, requestBuilder: builder)
        }

        factory { () -> SignUpCountriesClientAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            return SignUpCountriesClient(networkAdapter: adapter, requestBuilder: builder)
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
