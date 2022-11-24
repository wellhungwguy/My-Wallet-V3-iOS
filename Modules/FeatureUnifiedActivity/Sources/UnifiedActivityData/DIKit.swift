// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain
import DIKit
import NetworkKit
import UnifiedActivityDomain

extension DependencyContainer {

    // MARK: - DelegatedSelfCustodyData Module

    public static var unifiedActivityData = module {

        factory { LocaleIdentifierService() as LocaleIdentifierServiceAPI }

        single { () -> UnifiedActivityServiceAPI in
            UnifiedActivityService(
                webSocketService: .init(),
                requestBuilder: DIKit.resolve(tag: DIKitContext.websocket),
                authenticationDataRepository: DIKit.resolve(),
                fiatCurrencyServiceAPI: DIKit.resolve(),
                localeIdentifierService: DIKit.resolve()
            )
        }

        single { () -> UnifiedActivityPersistenceServiceAPI in
            UnifiedActivityPersistenceService(
                appDatabase: DIKit.resolve(),
                service: DIKit.resolve(),
                app: DIKit.resolve()
            )
        }

        single { () -> UnifiedActivityRepositoryAPI in
            UnifiedActivityRepository(
                appDatabase: DIKit.resolve(),
                activityEntityRequest: ActivityEntityRequest()
            )
        }

        single { () -> AppDatabaseAPI in
            AppDatabase.makeShared() as AppDatabaseAPI
        }
    }
}
