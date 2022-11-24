// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import Foundation
import NetworkKit

struct WalletInfoPollResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case responseType = "response_type"
    }

    enum ResponseType: String, Decodable {
        case walletInfo = "WALLET_INFO_POLLED"
        case continuePolling = "CONTINUE_POLLING"
        case requestDenied = "REQUEST_DENIED"
    }

    let responseType: ResponseType

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.responseType = try container.decode(ResponseType.self, forKey: .responseType)
    }
}

enum WalletInfoPollResultResponse {
    case walletInfo(WalletInfo)
    case continuePolling
    case requestDenied
}
