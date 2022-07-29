// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureCardIssuingDomain
import Foundation

protocol LegalClientAPI {

    func fetchLegalItems() -> AnyPublisher<[LegalItem], NabuNetworkError>
    func setAccepted(legalItems: [LegalItem]) -> AnyPublisher<[LegalItem], NabuNetworkError>
}
