// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProveDomain
import Foundation

public struct PrefillInfoRepository: PrefillInfoRepositoryAPI {
    private let client: PrefillInfoClientAPI

    public init(client: PrefillInfoClientAPI) {
        self.client = client
    }

    public func getPrefillInfo(
        dateOfBirth: Date
    ) -> AnyPublisher<PrefillInfo, NabuError> {
        client
            .getPrefillInfo(dateOfBirth: dateOfBirth)
            .map { response in
                PrefillInfo(
                    fullName: response.fullName,
                    dateOfBirth: dateOfBirth,
                    phone: response.phone
                )
            }
            .eraseToAnyPublisher()
    }
}
