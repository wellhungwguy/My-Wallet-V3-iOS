// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DelegatedSelfCustodyDomain
import DIKit
import NetworkKit
import UnifiedActivityDomain

extension DependencyContainer {

    // MARK: - DelegatedSelfCustodyData Module

    public static var unifiedActivityData = module {

        factory { LocaleIdentifierService() as LocaleIdentifierServiceAPI }

        single { () -> UnifiedActivityRepositoryAPI in
            UnifiedActivityRepository(
                service: UnifiedActivityService(
                    webSocketService: .init(),
                    requestBuilder: DIKit.resolve(tag: DIKitContext.websocket),
                    authenticationDataRepository: DIKit.resolve(),
                    fiatCurrencyServiceAPI: DIKit.resolve(),
                    localeIdentifierService: DIKit.resolve()
                ),
                app: DIKit.resolve()
            )
        }
    }
}
