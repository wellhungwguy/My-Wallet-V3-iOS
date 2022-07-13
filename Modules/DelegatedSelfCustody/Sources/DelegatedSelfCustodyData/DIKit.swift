// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain
import DIKit
import NetworkKit

extension DependencyContainer {

    // MARK: - DelegatedSelfCustodyData Module

    public static var delegatedSelfCustodyData = module {

        factory {
            Client(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve()
            )
        }

        factory { () -> AccountDataClientAPI in
            let client: Client = DIKit.resolve()
            return client as AccountDataClientAPI
        }

        factory { () -> SubscriptionsClientAPI in
            let client: Client = DIKit.resolve()
            return client as SubscriptionsClientAPI
        }

        factory { () -> AuthenticationClientAPI in
            let client: Client = DIKit.resolve()
            return client as AuthenticationClientAPI
        }

        factory { () -> TransactionsClientAPI in
            let client: Client = DIKit.resolve()
            return client as TransactionsClientAPI
        }

        single { () -> DelegatedCustodyBalanceRepositoryAPI in
            BalanceRepository(
                client: DIKit.resolve(),
                authenticationDataRepository: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve()
            )
        }

        factory {
            AssetSupportService(stacksSupport: DIKit.resolve())
        }

        single {
            AccountRepository(
                assetSupportService: DIKit.resolve(),
                derivationService: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve()
            )
        }

        factory { () -> AccountRepositoryAPI in
            let service: AccountRepository = DIKit.resolve()
            return service as AccountRepositoryAPI
        }

        factory { () -> DelegatedCustodyAccountRepositoryAPI in
            let service: AccountRepository = DIKit.resolve()
            return service as DelegatedCustodyAccountRepositoryAPI
        }

        factory { () -> AuthenticationDataRepositoryAPI in
            AuthenticationDataRepository(
                guidService: DIKit.resolve(),
                sharedKeyService: DIKit.resolve()
            )
        }

        factory { () -> DelegatedCustodySubscriptionsServiceAPI in
            SubscriptionsService(
                accountRepository: DIKit.resolve(),
                authClient: DIKit.resolve(),
                authenticationDataRepository: DIKit.resolve(),
                subscriptionsClient: DIKit.resolve(),
                subscriptionsStateService: DIKit.resolve()
            )
        }

        factory { () -> SubscriptionsStateServiceAPI in
            SubscriptionsStateService(
                accountRepository: DIKit.resolve(),
                app: DIKit.resolve()
            )
        }
    }
}
