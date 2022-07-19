// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct OptionsResponse: Equatable, Codable {
    let pbkdf2Iterations: Int
    let html5Notifications: Bool
    let logoutTime: Int
    let feePerKB: Int?

    enum CodingKeys: String, CodingKey {
        case pbkdf2Iterations = "pbkdf2_iterations"
        case feePerKB = "fee_per_kb"
        case html5Notifications = "html5_notifications"
        case logoutTime = "logout_time"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pbkdf2Iterations = try container.decode(Int.self, forKey: .pbkdf2Iterations)
        html5Notifications = try container.decodeIfPresent(Bool.self, forKey: .html5Notifications) ?? false
        logoutTime = try container.decode(Int.self, forKey: .logoutTime)
        feePerKB = try container.decodeIfPresent(Int.self, forKey: .feePerKB)
    }

    init(
        pbkdf2Iterations: Int,
        html5Notifications: Bool,
        logoutTime: Int,
        feePerKB: Int?
    ) {
        self.pbkdf2Iterations = pbkdf2Iterations
        self.html5Notifications = html5Notifications
        self.logoutTime = logoutTime
        self.feePerKB = feePerKB
    }
}

extension WalletPayloadKit.Options {
    static func from(model: OptionsResponse) -> Options {
        Options(
            pbkdf2Iterations: model.pbkdf2Iterations,
            feePerKB: model.feePerKB,
            html5Notifications: model.html5Notifications,
            logoutTime: model.logoutTime
        )
    }

    var toOptionsReponse: OptionsResponse {
        OptionsResponse(
            pbkdf2Iterations: pbkdf2Iterations,
            html5Notifications: html5Notifications,
            logoutTime: logoutTime,
            feePerKB: feePerKB
        )
    }
}
