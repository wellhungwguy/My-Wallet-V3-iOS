// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct FlowKYCInfoService: FlowKYCInfoServiceAPI {
    private let repository: FlowKYCInfoRepositoryAPI

    public init(repository: FlowKYCInfoRepositoryAPI) {
        self.repository = repository
    }

    public func getFlowKYCInfo() async throws -> FlowKYCInfo? {
        try await repository
            .getFlowKYCInfo()
            .await()
    }
}
