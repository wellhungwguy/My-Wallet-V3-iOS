// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureWalletConnectDomain
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - FeatureWalletConnectData Module

    public static var featureWalletConnectData = module {

        single { WalletConnectService() as WalletConnectServiceAPI }

        single { () -> SessionRepositoryAPI in
            SessionRepositoryMetadata(
                walletConnectFetcher: DIKit.resolve()
            )
        }
    }
}
