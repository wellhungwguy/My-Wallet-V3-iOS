// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol FlowKYCInfoClientAPI {

    func getKYCFlowInfo(
    ) -> AnyPublisher<FlowKYCInfoClientResponse, NabuError>
}
