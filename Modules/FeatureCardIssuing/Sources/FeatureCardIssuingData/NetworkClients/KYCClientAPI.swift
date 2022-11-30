// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation

public protocol KYCClientAPI {

    func update(_ parameters: KYCUpdateParameters) -> AnyPublisher<KYC, NabuNetworkError>

    func fetch() -> AnyPublisher<KYC, NabuNetworkError>
}

public struct KYCUpdateParameters: Encodable {
    let ssn: String?
    let address: Card.Address?

    public init(ssn: String?, address: Card.Address?) {
        self.address = address
        guard let ssn, ssn.isNotEmpty else {
            self.ssn = nil
            return
        }
        self.ssn = ssn
    }
}
