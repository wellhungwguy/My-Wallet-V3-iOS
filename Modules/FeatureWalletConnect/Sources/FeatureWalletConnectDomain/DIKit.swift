// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureWalletConnectDomain Module

    public static var featureWalletConnectDomain = module {

        factory { WalletConnectConsoleLogger() as WalletConnectConsoleLoggerAPI }

        factory { WalletConnectAccountProvider() as WalletConnectAccountProviderAPI }

        factory { WalletConnectAccountProvider() as WalletConnectPublicKeyProviderAPI }
    }
}
