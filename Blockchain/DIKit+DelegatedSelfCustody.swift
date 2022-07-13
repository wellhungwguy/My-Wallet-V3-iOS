// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable file_length

import Combine
import DelegatedSelfCustodyData
import DelegatedSelfCustodyDomain
import DIKit
import FeatureAuthenticationDomain
import MoneyKit
import PlatformKit
import WalletCore
import WalletPayloadKit

// MARK: - Blockchain Module

extension DependencyContainer {

    // swiftlint:disable closure_body_length
    static var blockchainDelegatedSelfCustody = module {
        factory { () -> DelegatedCustodyDerivationServiceAPI in
            DelegatedCustodyDerivationService(mnemonicAccess: DIKit.resolve())
        }
        factory { () -> DelegatedCustodyFiatCurrencyServiceAPI in
            DelegatedCustodyFiatCurrencyService(service: DIKit.resolve())
        }
        factory { () -> DelegatedCustodyGuidServiceAPI in
            DelegatedCustodyGuidService(service: DIKit.resolve())
        }
        factory { () -> DelegatedCustodySharedKeyServiceAPI in
            DelegatedCustodySharedKeyService(service: DIKit.resolve())
        }
        factory { () -> DelegatedCustodyStacksSupportServiceAPI in
            DelegatedCustodyStacksSupportService(
                app: DIKit.resolve(),
                nabuUserService: DIKit.resolve()
            )
        }
    }
}

final class DelegatedCustodyFiatCurrencyService: DelegatedCustodyFiatCurrencyServiceAPI {

    private let service: FiatCurrencyServiceAPI

    init(service: FiatCurrencyServiceAPI) {
        self.service = service
    }

    var fiatCurrency: AnyPublisher<FiatCurrency, Never> {
        service.displayCurrencyPublisher
    }
}

final class DelegatedCustodyGuidService: DelegatedCustodyGuidServiceAPI {

    private let service: FeatureAuthenticationDomain.GuidRepositoryAPI

    init(service: FeatureAuthenticationDomain.GuidRepositoryAPI) {
        self.service = service
    }

    var guid: AnyPublisher<String?, Never> {
        service.guid
    }
}

final class DelegatedCustodySharedKeyService: DelegatedCustodySharedKeyServiceAPI {

    private let service: FeatureAuthenticationDomain.SharedKeyRepositoryAPI

    init(service: FeatureAuthenticationDomain.SharedKeyRepositoryAPI) {
        self.service = service
    }

    var sharedKey: AnyPublisher<String?, Never> {
        service.sharedKey
    }
}

final class DelegatedCustodyStacksSupportService: DelegatedCustodyStacksSupportServiceAPI {

    private let app: AppProtocol
    private let nabuUserService: NabuUserServiceAPI

    init(
        app: AppProtocol,
        nabuUserService: NabuUserServiceAPI
    ) {
        self.app = app
        self.nabuUserService = nabuUserService
    }

    var isEnabled: AnyPublisher<Bool, Never> {
        allUsersIsEnabled
            .zip(airdropUsersIsEnabled)
            .flatMap { [nabuUserService] allUsersIsEnabled, airdropUsersIsEnabled -> AnyPublisher<Bool, Never> in
                if allUsersIsEnabled {
                    return .just(true)
                }
                if airdropUsersIsEnabled {
                    return nabuUserService
                        .user
                        .map(\.isBlockstackAirdropRegistered)
                        .replaceError(with: false)
                        .eraseToAnyPublisher()
                }
                return .just(false)
            }
            .eraseToAnyPublisher()
    }

    private var allUsersIsEnabled: AnyPublisher<Bool, Never> {
        app.publisher(
            for: blockchain.app.configuration.stx.all.users.is.enabled,
            as: Bool.self
        )
        .map(\.value)
        .replaceNil(with: false)
        .eraseToAnyPublisher()
    }

    private var airdropUsersIsEnabled: AnyPublisher<Bool, Never> {
        app.publisher(
            for: blockchain.app.configuration.stx.airdrop.users.is.enabled,
            as: Bool.self
        )
        .map(\.value)
        .replaceNil(with: false)
        .eraseToAnyPublisher()
    }
}

enum DelegatedCustodyDerivationServiceError: Error {
    case failed
}

final class DelegatedCustodyDerivationService: DelegatedCustodyDerivationServiceAPI {

    private let mnemonicAccess: WalletPayloadKit.MnemonicAccessAPI

    init(mnemonicAccess: WalletPayloadKit.MnemonicAccessAPI) {
        self.mnemonicAccess = mnemonicAccess
    }

    func getKeys(
        path: String
    ) -> AnyPublisher<(publicKey: Data, privateKey: Data), Error> {
        let mnemonic: AnyPublisher<WalletPayloadKit.Mnemonic, MnemonicAccessError> = mnemonicAccess.mnemonic
        return mnemonic
            .map { mnemonic -> (publicKey: Data, privateKey: Data)? in
                guard let wallet = WalletCore.HDWallet(mnemonic: mnemonic, passphrase: "") else {
                    return nil
                }
                let privateKey = wallet.getKey(coin: .bitcoin, derivationPath: path)
                let publicKey = privateKey.getPublicKeySecp256k1(compressed: true)
                return (publicKey: publicKey.data, privateKey: privateKey.data)
            }
            .eraseError()
            .onNil(DelegatedCustodyDerivationServiceError.failed)
            .eraseError()
            .eraseToAnyPublisher()
    }
}
