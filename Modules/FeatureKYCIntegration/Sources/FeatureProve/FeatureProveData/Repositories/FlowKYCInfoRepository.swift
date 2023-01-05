// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProveDomain

public struct FlowKYCInfoRepository: FlowKYCInfoRepositoryAPI {
    private let client: FlowKYCInfoClientAPI

    public init(client: FlowKYCInfoClientAPI) {
        self.client = client
    }

    public func getFlowKYCInfo(
    ) -> AnyPublisher<FlowKYCInfo, NabuError> {
        client
            .getKYCFlowInfo()
            .map { response in
                FlowKYCInfo(
                    nextFlow: response.nextFlow
                )
            }
            .eraseToAnyPublisher()
    }
}
