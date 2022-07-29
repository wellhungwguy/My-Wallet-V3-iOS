// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation

public protocol LegalRepositoryAPI {

    func fetchLegalItems() -> AnyPublisher<[LegalItem], NabuNetworkError>
    func setAccepted(legalItems: [LegalItem]) -> AnyPublisher<[LegalItem], NabuNetworkError>
}
