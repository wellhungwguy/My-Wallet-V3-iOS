// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol FlowKYCInfoRepositoryAPI {

    func getFlowKYCInfo() -> AnyPublisher<FlowKYCInfo, NabuError>
}
