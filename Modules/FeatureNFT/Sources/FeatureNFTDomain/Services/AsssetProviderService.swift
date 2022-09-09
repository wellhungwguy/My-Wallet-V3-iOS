// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import ToolKit

public enum AssetProviderServiceError: Error, Equatable {
    case failedToFetchEthereumWallet
    case network(NabuNetworkError)
}

public struct NFTAssetPage: Equatable {
    public let assets: [Asset]
    public let cursor: String?

    init(_ response: AssetPageResponse) {
        assets = response.assets
        cursor = response.next
    }
}

public protocol AssetProviderServiceAPI {
    var address: AnyPublisher<String, AssetProviderServiceError> { get }
    func fetchAssetsFromEthereumAddress()
    -> AnyPublisher<NFTAssetPage, AssetProviderServiceError>
    func fetchAssetsFromEthereumAddressWithCursor(_ cursor: String)
        -> AnyPublisher<NFTAssetPage, AssetProviderServiceError>
}

public final class AssetProviderService: AssetProviderServiceAPI {

    private let repository: AssetProviderRepositoryAPI
    private let ethereumWalletAddressPublisher: AnyPublisher<String, Error>

    public var address: AnyPublisher<String, AssetProviderServiceError> {
        ethereumWalletAddressPublisher
            .replaceError(
                with: AssetProviderServiceError.failedToFetchEthereumWallet
            )
            .eraseToAnyPublisher()
    }

    public init(
        repository: AssetProviderRepositoryAPI,
        ethereumWalletAddressPublisher: AnyPublisher<String, Error>
    ) {
        self.repository = repository
        self.ethereumWalletAddressPublisher = ethereumWalletAddressPublisher
    }

    public func fetchAssetsFromEthereumAddress()
        -> AnyPublisher<NFTAssetPage, AssetProviderServiceError>
    {
        ethereumWalletAddressPublisher
            .replaceError(
                with: AssetProviderServiceError.failedToFetchEthereumWallet
            )
            .flatMap { [repository] address in
                repository
                    .fetchAssetsFromEthereumAddress(address)
                    .map(NFTAssetPage.init)
                    .mapError(AssetProviderServiceError.network)
            }
            .eraseToAnyPublisher()
    }

    public func fetchAssetsFromEthereumAddressWithCursor(
        _ cursor: String
    ) -> AnyPublisher<NFTAssetPage, AssetProviderServiceError> {
        ethereumWalletAddressPublisher
            .replaceError(
                with: AssetProviderServiceError.failedToFetchEthereumWallet
            )
            .flatMap { [repository] address in
                repository
                    .fetchAssetsFromEthereumAddress(address, pageKey: cursor)
                    .map(NFTAssetPage.init)
                    .mapError(AssetProviderServiceError.network)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Preview Helper

extension AssetProviderService {

    public static var previewEmpty: AssetProviderService {
        AssetProviderService(
            repository: PreviewAssetProviderRepository(),
            ethereumWalletAddressPublisher: .empty()
        )
    }
}
