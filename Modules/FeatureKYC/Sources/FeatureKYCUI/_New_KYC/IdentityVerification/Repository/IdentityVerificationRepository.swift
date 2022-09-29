// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import PlatformKit

final class IdentityVerificationRepository {

    private let client: KYCClientAPI
    private var cache = [String: [KYCDocumentType]]()

    init(client: KYCClientAPI = resolve()) {
        self.client = client
    }

    func supportedDocumentTypes(
        countryCode: String
    ) -> AnyPublisher<[KYCDocumentType], NabuNetworkError> {
        if let types = cache[countryCode] {
            return .just(types)
        }

        return client
            .supportedDocuments(for: countryCode)
            .map { [weak self] documents in
                let documentTypes = documents.documentTypes
                self?.cache[countryCode] = documentTypes
                return documentTypes
            }
            .eraseToAnyPublisher()
    }
}
