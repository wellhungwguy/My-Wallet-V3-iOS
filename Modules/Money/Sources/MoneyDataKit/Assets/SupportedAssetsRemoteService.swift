// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MoneyDomainKit
import ToolKit

final class SupportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI {

    private let client: SupportedAssetsClientAPI
    private let filePathProvider: SupportedAssetsFilePathProviderAPI
    private let fileIO: FileIOAPI
    private let jsonDecoder: JSONEncoder

    init(
        client: SupportedAssetsClientAPI,
        filePathProvider: SupportedAssetsFilePathProviderAPI,
        fileIO: FileIOAPI,
        jsonDecoder: JSONEncoder
    ) {
        self.client = client
        self.filePathProvider = filePathProvider
        self.fileIO = fileIO
        self.jsonDecoder = jsonDecoder
    }

    func refreshCustodialAssetsCache() -> AnyPublisher<Void, Never> {
        client.custodialAssets
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.remoteCustodialAssets!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    func refreshEthereumERC20AssetsCache() -> AnyPublisher<Void, Never> {
        client.ethereumERC20Assets
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.remoteEthereumERC20Assets!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    func refreshOtherERC20AssetsCache() -> AnyPublisher<Void, Never> {
        client.otherERC20Assets
            .eraseError()
            .flatMap { [filePathProvider, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(
                        response,
                        to: filePathProvider.remoteOtherERC20Assets!,
                        encodedUsing: jsonDecoder
                    )
                    .eraseError()
                    .publisher
                    .eraseToAnyPublisher()
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
}
