// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import PlatformKit

final class PersonalDetailsService {

    private let client: KYCClientAPI

    init(client: KYCClientAPI = resolve()) {
        self.client = client
    }

    func update(firstName: String?, lastName: String?, birthday: Date?) -> AnyPublisher<Void, NabuNetworkError> {
        client.updatePersonalDetails(firstName: firstName, lastName: lastName, birthday: birthday)
    }
}
