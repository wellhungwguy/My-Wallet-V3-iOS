// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct ConfirmationRequiredError: Decodable {

    private enum CodingKeys: String, CodingKey {
        case requestTime = "request_time"
        case requester
        case approver
    }

    let requestTime: Date
    let requester: DeviceVerificationDetails
    let approver: DeviceVerificationDetails

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let epochTime = try container.decode(TimeInterval.self, forKey: .requestTime)
        // divide by 1000 to convert millseconds to seconds
        self.requestTime = Date(timeIntervalSince1970: epochTime / 1000)
        self.requester = try container.decode(DeviceVerificationDetails.self, forKey: .requester)
        self.approver = try container.decode(DeviceVerificationDetails.self, forKey: .approver)
    }
}
