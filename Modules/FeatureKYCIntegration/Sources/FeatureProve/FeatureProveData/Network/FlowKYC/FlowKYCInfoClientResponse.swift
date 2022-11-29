// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProveDomain

public struct FlowKYCInfoClientResponse: Decodable {
    let nextFlow: FlowKYCInfo.NextFlow?
}
