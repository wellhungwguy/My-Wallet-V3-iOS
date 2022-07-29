// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import ObservabilityKit
import ToolKit

/// Checks if wallet credentials on metadata needs updating.
/// - Note: This doesn't not produce an error intentionally
typealias CheckAndSaveWalletCredentials = (
    _ guid: String,
    _ sharedKey: String,
    _ password: String
) -> AnyPublisher<EmptyValue, Never>

final class WalletCredentialsFetcher {

    private let service: WalletMetadataEntryServiceAPI
    private let tracer: LogMessageServiceAPI

    init(
        service: WalletMetadataEntryServiceAPI,
        tracer: LogMessageServiceAPI
    ) {
        self.service = service
        self.tracer = tracer
    }

    func saveIfNeeded(
        guid: String,
        sharedKey: String,
        password: String
    ) -> AnyPublisher<EmptyValue, Never> {
        service.fetchEntry(type: WalletCredentialsEntryPayload.self)
            .catch { error -> AnyPublisher<WalletCredentialsEntryPayload, WalletAssetFetchError> in
                guard case .fetchFailed(.loadMetadataError(.notYetCreated)) = error else {
                    return .failure(error)
                }
                // in case of `notYetCreated` error we need to save the entry
                // we pass empty so that the following logic will save the entry
                return .just(WalletCredentialsEntryPayload.empty())
            }
            .mapError { _ in WalletAssetSaveError.notInitialized }
            .flatMap { [service] credentials -> AnyPublisher<EmptyValue, WalletAssetSaveError> in
                guard credentials.guid == guid,
                      credentials.sharedKey == sharedKey,
                      credentials.password == password
                else {
                    let updatedNode = WalletCredentialsEntryPayload(
                        guid: guid,
                        password: password,
                        sharedKey: sharedKey
                    )
                    return service.save(node: updatedNode)
                        .first()
                        .eraseToAnyPublisher()
                }
                return .just(.noValue)
            }
            .catch { [tracer] error -> EmptyValue in
                tracer.logError(error: error)
                return .noValue
            }
            .eraseToAnyPublisher()
    }
}

extension WalletCredentialsEntryPayload {
    static func empty() -> Self {
        WalletCredentialsEntryPayload(guid: "", password: "", sharedKey: "")
    }
}
