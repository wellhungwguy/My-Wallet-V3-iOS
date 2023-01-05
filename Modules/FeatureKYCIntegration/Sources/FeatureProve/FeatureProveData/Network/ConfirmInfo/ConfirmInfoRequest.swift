// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureProveDomain
import Foundation

public struct ConfirmInfoRequest: Encodable {

    private enum CodingKeys: String, CodingKey {
        case dateOfBirth = "dob"
    }

    let firstName: String
    let lastName: String
    let address: Address
    let dateOfBirth: Date
    let phone: String
}
