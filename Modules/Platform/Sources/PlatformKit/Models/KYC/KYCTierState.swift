// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension KYC.Tier {
    public enum State: String, Codable {
        case none
        case rejected
        case pending
        case verified
        case under_review
    }
}
