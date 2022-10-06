// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct ReverseResolutionRequest: Encodable {
    let address: String
    let currency: String
}
