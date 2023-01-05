// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PrefillInfoService: PrefillInfoServiceAPI {
    private let repository: PrefillInfoRepositoryAPI

    public init(repository: PrefillInfoRepositoryAPI) {
        self.repository = repository
    }

    public func getPrefillInfo(
        dateOfBirth: Date
    ) async throws -> PrefillInfo {
        try await repository
            .getPrefillInfo(dateOfBirth: dateOfBirth)
            .await()
    }
}
