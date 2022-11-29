// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct MobileAuthInfoService: MobileAuthInfoServiceAPI {
    private let repository: MobileAuthInfoRepositoryAPI

    public init(repository: MobileAuthInfoRepositoryAPI) {
        self.repository = repository
    }

    public func getMobileAuthInfo() async throws -> MobileAuthInfo? {
        try await repository
            .getMobileAuthInfo()
            .await()
    }
}
