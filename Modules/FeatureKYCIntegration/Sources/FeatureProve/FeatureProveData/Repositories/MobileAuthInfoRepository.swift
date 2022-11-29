// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProveDomain

public struct MobileAuthInfoRepository: MobileAuthInfoRepositoryAPI {
    private let client: MobileAuthInfoClientAPI

    public init(client: MobileAuthInfoClientAPI) {
        self.client = client
    }

    public func getMobileAuthInfo(
    ) -> AnyPublisher<MobileAuthInfo, NabuError> {
        client
            .getMobileAuthInfo()
            .map { response in
                MobileAuthInfo(
                    id: response.id,
                    phone: response.phone
                )
            }
            .eraseToAnyPublisher()
    }
}
