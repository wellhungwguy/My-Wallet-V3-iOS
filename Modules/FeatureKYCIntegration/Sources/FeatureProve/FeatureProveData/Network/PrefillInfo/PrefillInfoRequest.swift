// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProveDomain
import Foundation

public struct PrefillInfoRequest: Encodable {

    private enum CodingKeys: String, CodingKey {
        case dateOfBirth = "dob"
    }

    let dateOfBirth: Date
}
