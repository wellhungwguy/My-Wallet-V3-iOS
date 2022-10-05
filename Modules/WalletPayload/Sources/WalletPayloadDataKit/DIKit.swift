// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import KeychainKit
import NetworkKit
import ToolKit
import WalletPayloadKit

enum DIKitWalletPayloadTags {
    static let repoTag = "repo.tag"
    static let walletServer = "wallet.server"
    static let walletServerApi = "wallet.server.api"
}

extension DependencyContainer {

    // MARK: - walletPayloadDataKit Module

    public static var walletPayloadDataKit = module {

        factory { WalletPayloadClient() as WalletPayloadClientAPI }

        factory { WalletPayloadRepository() as WalletPayloadRepositoryAPI }

        factory(tag: DIKitWalletPayloadTags.walletServer) {
            RequestBuilder.walletServerBuilder()
        }

        factory(tag: DIKitWalletPayloadTags.walletServerApi) {
            RequestBuilder.walletApiBuilder()
        }

        factory { () -> ServerEntropyClientAPI in
            ServerEntropyClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve(tag: DIKitWalletPayloadTags.walletServerApi)
            )
        }

        factory { () -> ServerEntropyRepositoryAPI in
            ServerEntropyRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> CreateWalletClientAPI in
            let apiCode: APICode = DIKit.resolve()
            return CreateWalletClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve(tag: DIKitWalletPayloadTags.walletServer),
                apiCodeProvider: { apiCode }
            )
        }

        factory { () -> SaveWalletClientAPI in
            let apiCode: APICode = DIKit.resolve()
            return SaveWalletClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve(tag: DIKitWalletPayloadTags.walletServer),
                apiCodeProvider: { apiCode }
            )
        }

        factory { () -> CreateWalletRepositoryAPI in
            CreateWalletRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> SaveWalletRepositoryAPI in
            SaveWalletRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> WalletDecoderAPI in
            WalletDecoder() as WalletDecoderAPI
        }

        factory { () -> WalletEncodingAPI in
            WalletEncoder() as WalletEncodingAPI
        }

        factory { () -> WalletHolderAPI in
            let holder: WalletHolder = DIKit.resolve()
            return holder as WalletHolderAPI
        }

        single { WalletHolder() }

        single { () -> WalletRepoAPI in
            let keychainAccess: KeychainAccessAPI = DIKit.resolve(tag: DIKitWalletPayloadTags.repoTag)
            let initialStateOrEmpty = retrieveWalletRepoState(keychainAccess: keychainAccess) ?? .empty
            return WalletRepo(initialState: initialStateOrEmpty)
        }

        single { () -> WalletRepoPersistenceAPI in
            let repo: WalletRepoAPI = DIKit.resolve()
            let queue = DispatchQueue(label: "wallet.persistence.queue", qos: .default)
            let keychainAccess: KeychainAccessAPI = DIKit.resolve(tag: DIKitWalletPayloadTags.repoTag)
            return WalletRepoPersistence(
                repo: repo,
                keychainAccess: keychainAccess,
                queue: queue
            )
        }

        single(tag: DIKitWalletPayloadTags.repoTag) { () -> KeychainAccessAPI in
            let queryProvider = GenericPasswordQuery(
                service: "com.blockchain.wallet-repo",
                accessGroup: nil,
                permission: .whenUnlockedThisDeviceOnly,
                synchronizable: false
            )
            return KeychainAccess(queryProvider: queryProvider)
        }
    }
}

extension WalletPayloadData.Config {
    fileprivate static func wallet(
        code: APICode = resolve()
    ) -> WalletPayloadData.Config {
        WalletPayloadData.Config(
            host: InfoDictionaryHelper.value(for: .walletServer),
            code: code
        )
    }

    fileprivate static func walletApi(
        code: APICode = resolve()
    ) -> WalletPayloadData.Config {
        WalletPayloadData.Config(
            host: InfoDictionaryHelper.value(for: .apiURL),
            code: code
        )
    }
}

extension WalletPayloadData.Config {
    fileprivate static func walletServer(
        config: WalletPayloadData.Config = .wallet()
    ) -> Network.Config {
        Network.Config(
            scheme: "https",
            host: config.host,
            code: config.code,
            components: []
        )
    }

    fileprivate static func walletApi(
        config: WalletPayloadData.Config = .walletApi()
    ) -> Network.Config {
        Network.Config(
            scheme: "https",
            host: config.host,
            code: config.code,
            components: []
        )
    }
}

extension RequestBuilder {

    fileprivate static func walletServerBuilder(
    ) -> RequestBuilder {
        RequestBuilder(
            config: WalletPayloadData.Config.walletServer()
        )
    }

    fileprivate static func walletApiBuilder(
    ) -> RequestBuilder {
        RequestBuilder(
            config: WalletPayloadData.Config.walletApi()
        )
    }
}
